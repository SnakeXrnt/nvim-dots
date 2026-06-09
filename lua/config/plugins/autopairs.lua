return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local npairs = require("nvim-autopairs")
    npairs.setup({
      check_ts = true,
      map_cr = true,
    })

    -- This specific block handles the "Enter" behavior for brackets
    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')

    npairs.add_rules({
      -- Rule for putting a space between brackets
      Rule(' ', ' ')
        :with_pair(function (opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ '()', '[]', '{}' }, pair)
        end),
    })
  end,
}
