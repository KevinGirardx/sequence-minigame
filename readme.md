![alt text](logowithtext.png)

# This is a minigame Inspired by NoPixel

![Symbols, Letter & Numbers](image.png)
![Letters](image-1.png)

# Useage:

```lua
    exports['sequence-minigame']:KeySequence(function (success)
        if success then
            print('success')
        else
            print('failure')
        end
    end, 10, 'alphabet') -- time in seconds, type = ("alphabet" which show only letters / "all" which shows letters, symbols, and numbers)
```