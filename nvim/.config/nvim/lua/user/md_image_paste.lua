local M = {}

local function clipboard_file_alias()
  local as = [[
    try
      return POSIX path of (the clipboard as alias)
    on error
      return ""
    end try
  ]]
  return vim.fn.system({ "osascript", "-e", as }):gsub("%s+$", "")
end

local function clipboard_file_url()
  local jxa = [[
    ObjC.import("AppKit");
    function run() {
      var pb = $.NSPasteboard.generalPasteboard;
      var items = pb.pasteboardItems;
      if (!items) return "";
      for (var i = 0; i < items.count; i++) {
        var it = items.objectAtIndex(i);
        var d = it.dataForType("public.file-url");
        if (d) {
          var s = $.NSString.alloc.initWithDataEncoding(d, $.NSUTF8StringEncoding).js;
          return decodeURI(s.replace(/^file:\/\//, "").replace(/\n/g, ""));
        }
      }
      return "";
    }
  ]]
  return vim.fn.system({ "osascript", "-l", "JavaScript", "-e", jxa }):gsub("%s+$", "")
end

local function finder_selection_path()
  local as = [[
    tell application "Finder"
      if (count of selection) > 0 then
        return POSIX path of (item 1 of selection as alias)
      else
        return ""
      end if
    end tell
  ]]
  return vim.fn.system({ "osascript", "-e", as }):gsub("%s+$", "")
end

local function is_image(path)
  local ext = (path:match("%.([%w]+)$") or ""):lower()
  return ext:match("^(png|jpe?g|gif|webp|tif?f|bmp|heic)$") ~= nil
end

M.paste = function()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    vim.notify("Save the file first so I know where to create ./assets", vim.log.levels.WARN)
    return
  end
  local assets = dir .. "/assets"
  vim.fn.mkdir(assets, "p")
  local ts = os.date("%Y-%m-%d-%H%M%S")

  -- 1) clipboard alias (most reliable for Finder ⌘C)
  local src = clipboard_file_alias()
  if src == "" then
    src = clipboard_file_url()
  end -- 2) file-URL on clipboard
  if src == "" then
    src = finder_selection_path()
  end -- 3) current Finder selection

  if src ~= "" and is_image(src) then
    local ext = (src:match("%.([%w]+)$") or ""):lower()
    local fname, dst
    if ext == "heic" then
      fname = ts .. ".png"
      dst = assets .. "/" .. fname
      vim.fn.system({ "magick", src, dst })
    else
      fname = vim.fn.fnamemodify(src, ":t")
      dst = assets .. "/" .. fname
      if vim.fn.filereadable(dst) == 1 then
        local root = fname:match("(.+)%..+$") or fname
        fname = string.format("%s-%s.%s", root, ts, ext)
        dst = assets .. "/" .. fname
      end
      vim.fn.system({ "cp", src, dst })
    end
    if vim.v.shell_error == 0 and vim.fn.filereadable(dst) == 1 then
      vim.api.nvim_put({ string.format("![%s](assets/%s)", fname, fname) }, "l", true, true)
      return
    end
  end

  -- 4) last resort: raw image data (clipboard screenshot)
  local dst_png = string.format("%s/%s.png", assets, ts)
  vim.fn.system({ "pngpaste", dst_png })
  if vim.v.shell_error == 0 and vim.fn.filereadable(dst_png) == 1 then
    vim.api.nvim_put({ string.format("![%s](assets/%s.png)", ts, ts) }, "l", true, true)
    return
  end

  vim.notify("No image file on clipboard/selection and no raw image data.", vim.log.levels.WARN)
end

return M
