-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

map("i", "jk", "<esc>", { desc = "Go to normal mode" })
map("i", "kk", "<esc>", { desc = "Go to normal mode" })
map("i", "kj", "<esc>", { desc = "Go to normal mode" })
map("i", "jj", "<esc>", { desc = "Go to normal mode" })
