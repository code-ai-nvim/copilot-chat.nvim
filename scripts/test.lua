vim.opt.runtimepath:append(vim.fn.getcwd())

local dependencies = {
  ['plenary.nvim'] = 'https://github.com/nvim-lua/plenary.nvim',
}

for name, url in pairs(dependencies) do
  local install_path = vim.fn.fnamemodify('.dependencies/' .. name, ':p')
  if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system({ 'git', 'clone', '--depth=1', url, install_path })
  end
  vim.opt.runtimepath:append(install_path)
end

-- Every spec file runs in its own nvim process: force it to use the minimal init
-- instead of the user's personal config, and run sequentially for deterministic output.
require('plenary.test_harness').test_directory('tests', {
  minimal_init = 'scripts/minimal.lua',
  sequential = true,
  timeout = 60000,
})
