-- keymaps.lua
-- Global keymaps (non-plugin specific)

local opts = { noremap = true, silent = true }

-- Disable Q (ex mode)
vim.keymap.set('n', 'Q', '<Nop>')

-- Clear search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', opts)
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Swedish keyboard layout: Remap hjkl to jklö
vim.keymap.set({ 'n', 'v' }, 'h', '<Nop>')
vim.keymap.set({ 'n', 'v' }, 'j', '<Left>', opts)
vim.keymap.set({ 'n', 'v' }, 'k', '<Down>', opts)
vim.keymap.set({ 'n', 'v' }, 'l', '<Up>', opts)
vim.keymap.set({ 'n', 'v' }, 'ö', '<Right>', opts)

-- Window navigation (Swedish layout)
vim.keymap.set({ 'n', 'v' }, '<C-w>j', '<C-w><Left>', opts)
vim.keymap.set({ 'n', 'v' }, '<C-w>k', '<C-w><Down>', opts)
vim.keymap.set({ 'n', 'v' }, '<C-w>l', '<C-w><Up>', opts)
vim.keymap.set({ 'n', 'v' }, '<C-w>ö', '<C-w><Right>', opts)

-- Indentation in visual mode
vim.keymap.set('v', '<S-Tab>', '<gv', opts)
vim.keymap.set('v', '<Tab>', '>gv', opts)

-- Move lines in visual mode (Swedish layout: K=down, L=up)
vim.keymap.set('v', 'K', ":m '>+1<CR>gv=gv", opts)
vim.keymap.set('v', 'L', ":m '<-2<CR>gv=gv", opts)

-- Better scrolling (center view)
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Center view when searching
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Copilot placeholder keymaps (actual mapping in plugin)
vim.keymap.set({ 'n', 'v', 'i' }, '<M-m>', '<Nop>')
vim.keymap.set({ 'n', 'v', 'i' }, '<M-n>', '<Nop>')

-- Utility
vim.keymap.set('n', '<leader>dtu', ':%s/\\r//g<CR>', { noremap = true, silent = false, desc = 'Remove ^M from buffer' })

-- Git keymaps (vim-fugitive)
vim.keymap.set('n', '<leader>gs', ':G<cr>', { desc = '[G]it [S]tatus' })
vim.keymap.set('n', '<leader>gc', ':G commit<cr>', { desc = '[G]it [C]ommit' })
vim.keymap.set('n', '<leader>gp', ':G push<cr>', { desc = '[G]it [P]ush' })
vim.keymap.set('n', '<leader>gl', ':G pull<cr>', { desc = '[G]it Pu[l]l' })
vim.keymap.set('n', '<leader>gb', ':G blame<cr>', { desc = '[G]it [B]lame' })
vim.keymap.set('n', '<leader>gd', ':G diff<cr>', { desc = '[G]it [D]iff' })
vim.keymap.set('n', '<leader>gD', ':G diff --cached<cr>', { desc = '[G]it [D]iff Cached' })
vim.keymap.set('n', '<leader>gj', ':diffget //3<cr>', { desc = '[G]it diffget //3' })
vim.keymap.set('n', '<leader>gk', ':diffget //2<cr>', { desc = '[G]it diffget //2' })
vim.keymap.set('n', '<leader>gr', ':G rebase<cr>', { desc = '[G]it [R]ebase' })
vim.keymap.set('n', '<leader>gR', ':G rebase --continue<cr>', { desc = '[G]it [R]ebase Continue' })
vim.keymap.set('n', '<leader>gq', ':G rebase --quit<cr>', { desc = '[G]it rebase [Q]uit' })
vim.keymap.set('n', '<leader>ga', ':G rebase --abort<cr>', { desc = '[G]it rebase [A]bort' })
vim.keymap.set('n', '<leader>gS', ':G stash<cr>', { desc = '[G]it [S]tash' })
