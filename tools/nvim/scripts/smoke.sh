#!/usr/bin/env bash
set -uo pipefail

unset NVIM_APPNAME

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
smoke_lua="$script_dir/smoke.lua"
lua_arg="${smoke_lua// /\\ }"

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/nvim-smoke.XXXXXX")"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/src" "$tmpdir/.git"

cat > "$tmpdir/fixture.lua" <<'EOF'
local M = {}

function M.greet(name)
  return 'hello ' .. name
end

return M
EOF

cat > "$tmpdir/fixture.py" <<'EOF'
def greet(name: str) -> str:
    return f"hello {name}"
EOF

cat > "$tmpdir/package.json" <<'EOF'
{"name": "smoke-fixture", "private": true, "version": "0.0.0"}
EOF

cat > "$tmpdir/tsconfig.json" <<'EOF'
{"compilerOptions": {"strict": true, "target": "ES2022", "module": "ESNext"}}
EOF

cat > "$tmpdir/fixture.ts" <<'EOF'
export function greet(name: string): string {
  return `hello ${name}`;
}
EOF

cat > "$tmpdir/fixture.tsx" <<'EOF'
export function Greet({ name }: { name: string }) {
  return <p>hello {name}</p>;
}
EOF

cat > "$tmpdir/fixture.js" <<'EOF'
export function greet(name) {
  return `hello ${name}`;
}
EOF

cat > "$tmpdir/Cargo.toml" <<'EOF'
[package]
name = "smoke_fixture"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF

cat > "$tmpdir/src/main.rs" <<'EOF'
fn greet(name: &str) -> String {
    format!("hello {name}")
}

fn main() {
    println!("{}", greet("world"));
}
EOF

cat > "$tmpdir/fixture.md" <<'EOF'
# Smoke

Some **markdown** text.
EOF

cat > "$tmpdir/fixture.json" <<'EOF'
{"name": "smoke", "value": 1}
EOF

cat > "$tmpdir/fixture.sql" <<'EOF'
SELECT id, name FROM users WHERE id = 1;
EOF

cat > "$tmpdir/fixture.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "hello"
EOF

cat > "$tmpdir/fixture.html" <<'EOF'
<!doctype html>
<html><body><p>hello</p></body></html>
EOF

cat > "$tmpdir/fixture.yaml" <<'EOF'
name: smoke
value: 1
EOF

cat > "$tmpdir/fixture.toml" <<'EOF'
name = "smoke"
value = 1
EOF

cat > "$tmpdir/fixture.vim" <<'EOF'
let g:smoke = 1
EOF

seq 1 60 > "$tmpdir/long.txt"
seq 1 60 > "$tmpdir/with space.txt"

cat > "$tmpdir/.git/COMMIT_EDITMSG" <<'EOF'
smoke: test commit
EOF

mkdir -p "$tmpdir/bin"
cat > "$tmpdir/bin/lazygit" <<'EOF'
#!/usr/bin/env bash
if [[ -n ${LAZYGIT_STUB_EXIT:-} ]]; then
  exit "$LAZYGIT_STUB_EXIT"
fi
sleep 30
EOF
chmod +x "$tmpdir/bin/lazygit"

gitrepo="$tmpdir/gitrepo"
mkdir -p "$gitrepo"
git -C "$gitrepo" init -q
printf 'one\ntwo\n' >"$gitrepo/tracked.txt"
git -C "$gitrepo" add tracked.txt
git -C "$gitrepo" -c user.email=smoke@example.com -c user.name=smoke commit -qm smoke
printf 'three\n' >>"$gitrepo/tracked.txt"

results=""

report() {
  local status=$1 name=$2 detail=${3:-}
  local line="$status $name"
  if [[ -n $detail ]]; then
    line+=" ($detail)"
  fi
  results+="$line"$'\n'
  printf '%s\n' "$line"
}

run_nvim() {
  local name=$1 dir=$2
  shift 2
  local out rc
  out=$(cd "$dir" && "$@" 2>&1)
  rc=$?
  results+="$out"$'\n'
  if [[ -n $out ]]; then
    printf '%s\n' "$out"
  fi
  if (( rc != 0 )) && ! grep -q '^FAIL ' <<<"$out"; then
    report FAIL "$name" "nvim exited $rc"
  fi
}

if (cd "$tmpdir" && nvim --headless +qa >"$tmpdir/startup.out" 2>"$tmpdir/startup.err"); then
  startup_rc=0
else
  startup_rc=$?
fi
if (( startup_rc == 0 )) && [[ ! -s "$tmpdir/startup.err" ]]; then
  report PASS 'startup stderr'
else
  report FAIL 'startup stderr' "exit $startup_rc: $(tr '\n' ' ' <"$tmpdir/startup.err")"
fi

run_nvim startup "$tmpdir" env SMOKE_MODE=startup nvim --headless -c "luafile $lua_arg"

fixtures=(
  'lua|fixture.lua'
  'python|fixture.py'
  'typescript|fixture.ts'
  'typescriptreact|fixture.tsx'
  'javascript|fixture.js'
  'rust|src/main.rs'
  'markdown|fixture.md'
  'json|fixture.json'
  'sql|fixture.sql'
  'sh|fixture.sh'
  'html|fixture.html'
  'yaml|fixture.yaml'
  'toml|fixture.toml'
  'vim|fixture.vim'
  'gitcommit|.git/COMMIT_EDITMSG'
)

for fixture in "${fixtures[@]}"; do
  ft="${fixture%%|*}"
  path="${fixture#*|}"
  run_nvim "filetype $ft" "$tmpdir" env SMOKE_MODE=filetype SMOKE_FT="$ft" nvim --headless "$path" -c "luafile $lua_arg"
done

run_nvim neotree "$tmpdir" env SMOKE_MODE=neotree nvim --headless . -c "luafile $lua_arg"

run_nvim lazygit "$tmpdir" env SMOKE_MODE=lazygit PATH="$tmpdir/bin:$PATH" nvim --headless -c "luafile $lua_arg"

run_nvim health "$tmpdir" env SMOKE_MODE=health nvim --headless -c "luafile $lua_arg"

run_nvim gitsigns "$gitrepo" env SMOKE_MODE=gitsigns nvim --headless tracked.txt -c "luafile $lua_arg"

if (cd "$tmpdir" && nvim --headless --startuptime "$tmpdir/startuptime.log" +qa >/dev/null 2>&1); then
  total="$(awk '/NVIM STARTED/ { printf "%.1f", $1; exit }' "$tmpdir/startuptime.log")"
  report INFO 'startup time' "${total:-unknown} ms"
else
  report INFO 'startup time' 'unavailable'
fi

passed=$(grep -c '^PASS ' <<<"$results" || true)
failed=$(grep -c '^FAIL ' <<<"$results" || true)
skipped=$(grep -c '^SKIP ' <<<"$results" || true)

printf '\nSummary: %s passed, %s failed, %s skipped\n' "$passed" "$failed" "$skipped"

(( failed == 0 ))
