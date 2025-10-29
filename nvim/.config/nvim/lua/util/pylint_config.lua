local M = {}

---Return the best pylint for the current working tree.
---• <cwd>/.venv/bin/pylint or <cwd>/venv/bin/pylint if they exist
---• otherwise ~/.local/bin/pylint (pipx or --user install)
function M.resolve()
  local cwd = vim.fn.getcwd()
  for _, venv in ipairs({ ".venv", "venv" }) do
    local candidate = ("%s/%s/bin/pylint"):format(cwd, venv)
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return vim.fn.expand("~/.local/bin/pylint")
end

return M
