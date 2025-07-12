local dialogdata = {
  newgame = {
    name = "Captain Ray",
    icon = "assets/sprites/characterframes/CC_captainRay_001.png",
    text = "Welcome <c#4a52e1>aboard</c>. Looks like it's your <i10>first time</i> playing. (Press Enter to continue)",
    ["next-dialog"] = {
      name = "Captain Ray",
      icon = "assets/sprites/characterframes/CC_captainRay_001.png",
      text = "Would you like to go through a quick tutorial? Use the left and right keys to choose, then press Enter.",
      options = {
        {
          text = "Yes, show me how it works.",
          callback = function()
            -- leave empty or define later in your code
          end
        },
        {
          text = "No, I've played before.",
          callback = function()
            -- leave empty or define later in your code
          end
        }
      },
      ["next-dialog"] = nil -- explicitly mark no further dialog
    }
  },
}

return dialogdata
