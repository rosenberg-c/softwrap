local M = {}
local state = {
  float_win = nil,
  float_prev_win = nil,
  float_buf = nil,
  dim_win = nil,
  float_cleanup_id = nil,
  split_win = nil,
  split_prev_win = nil,
}

local function apply_wrap_opts(width)
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.breakindent = true
  vim.opt_local.colorcolumn = tostring(width)
end

function M.toggle_float(width)
  width = width or 80

  if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
    vim.api.nvim_win_close(state.float_win, true)
    state.float_win = nil
    if state.float_buf and vim.api.nvim_buf_is_valid(state.float_buf) then
      pcall(vim.keymap.del, "n", "<Esc>", { buffer = state.float_buf })
    end
    state.float_buf = nil
    if state.dim_win and vim.api.nvim_win_is_valid(state.dim_win) then
      vim.api.nvim_win_close(state.dim_win, true)
      state.dim_win = nil
    end
    if state.float_cleanup_id then
      vim.api.nvim_del_autocmd(state.float_cleanup_id)
      state.float_cleanup_id = nil
    end
    if state.float_prev_win and vim.api.nvim_win_is_valid(state.float_prev_win) then
      vim.api.nvim_set_current_win(state.float_prev_win)
    end
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines
  local win_width = math.min(width, editor_width - 4)
  local win_height = editor_height - 4
  local col = math.floor((editor_width - win_width) / 2)
  local row = 1

  state.float_prev_win = vim.api.nvim_get_current_win()
  state.float_buf = buf

  local dim_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[dim_buf].buftype = "nofile"
  vim.bo[dim_buf].bufhidden = "wipe"
  vim.bo[dim_buf].swapfile = false
  vim.api.nvim_set_hl(0, "SoftWrapDim", { bg = "#000000", fg = "#000000" })
  state.dim_win = vim.api.nvim_open_win(dim_buf, false, {
    relative = "editor",
    row = 0,
    col = 0,
    width = editor_width,
    height = editor_height,
    style = "minimal",
    focusable = false,
    zindex = 1,
  })
  vim.api.nvim_win_set_option(state.dim_win, "winhl", "Normal:SoftWrapDim")
  vim.api.nvim_win_set_option(state.dim_win, "winblend", 30)

  state.float_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = win_width,
    height = win_height,
    style = "minimal",
    border = "rounded",
    zindex = 2,
  })

  vim.keymap.set("n", "<Esc>", function()
    M.toggle_float(width)
  end, { buffer = buf, nowait = true, silent = true })

  state.float_cleanup_id = vim.api.nvim_create_autocmd("WinClosed", {
    once = true,
    callback = function()
      if state.dim_win and vim.api.nvim_win_is_valid(state.dim_win) then
        vim.api.nvim_win_close(state.dim_win, true)
      end
      state.float_win = nil
      if state.float_buf and vim.api.nvim_buf_is_valid(state.float_buf) then
        pcall(vim.keymap.del, "n", "<Esc>", { buffer = state.float_buf })
      end
      state.float_buf = nil
      state.dim_win = nil
      state.float_cleanup_id = nil
    end,
  })

  apply_wrap_opts(width)
end

function M.toggle_split(width)
  width = width or 80

  if state.split_win and vim.api.nvim_win_is_valid(state.split_win) then
    vim.api.nvim_win_close(state.split_win, true)
    state.split_win = nil
    if state.split_prev_win and vim.api.nvim_win_is_valid(state.split_prev_win) then
      vim.api.nvim_set_current_win(state.split_prev_win)
    end
    return
  end

  state.split_prev_win = vim.api.nvim_get_current_win()

  vim.cmd("vsplit")
  state.split_win = vim.api.nvim_get_current_win()

  local pad_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(pad_buf, "SoftWrapPadding")
  vim.bo[pad_buf].buftype = "nofile"
  vim.bo[pad_buf].bufhidden = "wipe"
  vim.bo[pad_buf].swapfile = false
  vim.api.nvim_win_set_buf(state.split_win, pad_buf)

  if vim.api.nvim_win_is_valid(state.split_prev_win) then
    vim.api.nvim_set_current_win(state.split_prev_win)
    vim.api.nvim_win_set_width(state.split_prev_win, width)
    apply_wrap_opts(width)
  end
end

return M
