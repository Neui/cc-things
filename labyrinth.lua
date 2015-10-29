-- Made by Neui

local path = {} -- Current path taken
local selection = 1 -- Current selection
local current_text = ""
local allow_back = true
local default_back = true
local allow_restart = true
local options = {} -- Options
local all_options = {} -- options + a few more special ones
local laby = {} -- Current loaded labyrinth
local running = false
local redraw = true

local cheats = {
  ["back"] = true; -- press backspace to go back
}

--[[
Syntax for the labyrinth (in the table)
laby = {
  ["$__terminate"] = "Message that will show then terminating the program";
  ["$__text"] = "Choose your option";
  ["option 1"] = {
    ["$__text"] = "You only got one way";
    ["option 1 1"] = {
      ["$__text"] = "The door behind you closed. You slowly see that you hardly get any air. After a while, you die due to missing air.";
      ["$__no_back"] = true; -- Don't give a option to go back
      ["$__restart"] = true; -- Give a option to restart
    };
  };
  ["option 2"] = {
    ["$__text"] = "You face a wall.";
  };
  ["This option is super long so that we can test some things. AlsoWeNeedARealLongWord!Yayayaya!"] = {
    
  };
}

]]

-- Taken from https://github.com/illacceptanything/illacceptanything/tree/master/labyrinth/
local default_labyrinth = {
  ["$__terminate"] = "You think about your life. You can't take it anymore and killed yourself.";
  ["$__text"] = "A labyrinth lies ahead.";
  ["$__default_back"] = false;
  ["$__exit"] = true;
  ["enter"] = {
    ["$__text"] = "A dead end. You blink. The labyrinth walls appear to be shifting and swaying. Perhaps if you return later, a path will open up.";
    ["$__exit"] = true;
    ["forward"] = {
      ["$__text"] = "Bumped into a wall. Good job.";
      ["$__exit"] = true;
      ["forward"] = {
        ["$__text"] = "Bumped into a wall. Again. Good job.";
        ["$__exit"] = true;
        ["FORWARD"] = {
          ["$__text"] = "You calmly walk into the next room.";
          ["left"] = {
            ["right"] = {
              ["$__text"] = "You are here.";
              ["$__back"] = true;
            };
            ["up"] = {
              ["up"] = {
                ["down"] = {
                  ["down"] = {
                    ["left"] = {
                      ["right"] = {
                        ["left"] = {
                          ["down"] = {
                            ["$__text"] = "DARN IT";
                            ["$__back"] = true;
                          };
                          ["right"] = {
                            ["B"] = {
                              ["A"] = {
                                ["START"] = {
                                  ["SELECT"] = {
                                    ["$__text"] = "Skrillex and Michael Jordan appear and grant you invincibility.";
                                  };
                                };
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
          ["right"] = {
            ["$__text"] = "A tall dwarf whispers in your ear, \"Today is not yet time.\" You shudder involuntarily.";
            ["ok"] = {
              ["$__text"] = "You walk into a room with five doors. One is clearly labeled \"WRONG WAY BAD DEATH.\"";
              ["Take the door labeled \"WRONG WAY BAD DEATH\""] = {
                ["$__text"] = "You go the wrong way and die a bad death.";
                ["forward"] = {
                  ["$__text"] = "A gazebo eyes you suspiciously.";
                  ["continue forward"] = {
                    ["$__text"] = "You reach a dead end And go back.";
                    ["$__back"] = true;
                  };
                  ["fight the gazebo"] = {
                    ["$__text"] = "You fight the gazebo for 3 days, die, and are reincarnated as Gandalf the White.";
                  };
                };
                ["left"] = {
                  ["$__text"] = "You find a Power Star, returning power to the castle.";
                };
                ["right"] = {
                  ["$__text"] = "You can't go right! You're dead.";
                  ["ok"] = {
                    ["$__text"] = "You walk into a room with five doors. One is clearly labeled \"WRONG WAY BAD DEATH.\"";
                    ["Take the door labeled \"WRONG WAY BAD DEATH\""] = {
                      ["$__text"] = "You go the bad way and die a wrong death. Sorry!";
                    };
                    ["Take the fifth door."] = {
                      ["$__text"] = "There is nothing interesting here.";
                    };
                    ["Take the first door"] = {
                      ["$__text"] = "There is a bicycle in the middle of the room.";
                      ["Mount bicycle"] = {
                        ["$__text"] = "PROF. OAK- \"This isn't the time to use that!\"";
                      };
                    };
                    ["Take the fourth door"] = {
                      ["$__text"] = "You go the right way and live a good life.";
                    };
                    ["Take the second door"] = {
                      ["$__text"] = "There are two doors and two guards in front of you. Before you can ask any questions, all three of you are eaten by a bobcat that only tells lies.";
                    };
                  };
                };
              };
              ["Take the fifth door"] = {
                ["$__text"] = "You walk into a city of tall dwarves. They stab you with sporks, shouting, \"No! Not today!\"";
                ["go around city"] = {
                  ["$__text"] = "You fall into the lava moat. Too bad!";
                };
                ["head into city"] = {
                  ["$__text"] = "The streets are lined with thousands of spork vendors.";
                  ["buy a spork"] = {
                    ["$__text"] = "You now have a spork.";
                    ["leave the way you came"] = {
                      ["$__text"] = "On the way out, you dodge the lava moat, but fall into the spork moat.";
                    };
                    ["continue through city"] = {
                      ["$__text"] = "The Spork Enforcer acknoledges your spork by shouting your name three times with increaing chutzpah.";
                      ["ok"] = {
                        ["$__text"] = "I'm going to be level, I got bored here. You'll have to add and commit the rest of the labyrinth yourself.";
                        ["git commit -m \"add the rest of the labyrinth\""] = {
                          ["$__text"] = "You add the rest of the labyrinth.";
                          ["celebrate"] = {
                            ["$__text"] = "You celebrate! Unfortunately, the nearby Spork Enforcer takes this as a sign of aggression, and sounds the spork alarm. Which is a bit like a regular alarm, but with sporks.";
                            ["ok"] = {
                              ["$__text"] = "You are surrounded by tall angry sporken dwarven. What do you do?";
                              ["fight"] = {
                                ["$__text"] = "You fight to your death.";
                              };
                              ["punch monty in the face"] = {
                                ["$__text"] = "You don't really know who Monty is, but decide that punching him in the face is the best course of action. It is extremely satisfying.";
                                ["ok"] = {
                                  ["$__text"] = "Unfortunately, the sporky dwarves take the opportunity to spork you in the shins. You cannot walk.";
                                  ["crawl away"] = {
                                    ["$__text"] = "You crawl out of the city, dodging the lava moat and crawling safely across the spork moat. The dwarves shout obscenities at you as you leave.";
                                    ["ok"] = {
                                      ["$__text"] = "You are in a large, open room. A faint glowing light can be seen to your left.";
                                      ["crawl down"] = {
                                        ["$__text"] = "You burrow under the ground. It is cozy.";
                                        ["hibernate"] = {
                                          ["$__text"] = "You hibernate until the release of the sequel, Labyrinth 2: The Return of Monty.";
                                        };
                                      };
                                      ["crawl forward"] = {
                                        ["$__text"] = "An ocean lies before you. Or I suppose you lie before an ocean. Whatever. There's a boat.";
                                        ["swim"] = {
                                          ["$__text"] = "You decide to go for a swim, despite the condition of your legs. You are immediately consumed by seals.";
                                        };
                                        ["take the boat"] = {
                                          ["$__text"] = "You now have the boat.";
                                          ["swim"] = {
                                            ["$__text"] = "You decide to swim across the ocean. The weight of the boat immediately drags you to the bottom of the sea. You drown.";
                                          };
                                        };
                                      };
                                      ["crawl left"] = {
                                        ["$__text"] = "After crawling for several minutes, you find yourself lying before a desktop computer. The Windows 95 logo bounces around unenthusiastically.";
                                        ["install gentoo"] = {
                                          ["$__text"] = "You decide to install Gentoo Linux. After struggling for several days trying to get the kernel to mount your EXT4 partition, you succeed, and find yourself in a terminal shell.";
                                          ["cat urandom"] = {
                                            ["$__text"] = "=$x71O2E!# gD*ar)[%lvYsDc!!Evt>V=v:c^w&9xzN;xb[^L<N%3(rP:K[6M\\oIbC9UnFg\"OXs3sN!Ee\\fC(%:3( `IqgC2:(GaPXQB[W\\ \"\"5#s&70tJY?_zGmA:f'<Ja eI84J`\"' X-\\9P9#_^>$'$j _0PsI>y8wqrX\".3tmZ.=+~00MftY3[`<QZ77I `JP`tAN";
                                          };
                                          ["play nethack"] = {
                                            ["$__text"] = "You play NetHack. Inevitably, you die.";
                                          };
                                        };
                                        ["it is time"] = {
                                          ["$__text"] = "It is time. Those dwarves, they were wrong. Today is the day.";
                                          ["ok"] = {
                                            ["$__text"] = "You navigate to github.com to start a new repository, one to end all others, and to bring about the end of us all.";
                                            ["ok"] = {
                                              ["$__text"] = "You're not quite sure what it is, or what it will become, but you figure if you accept enough pull request then eventually it will become clear.";
                                              ["accept a pull request"] = {
                                                ["$__text"] = "You accept a pull request.";
                                                ["accept a pull request"] = {
                                                  ["$__text"] = "You accept a pull request.";
                                                  ["accept a pull request"] = {
                                                    ["$__text"] = "You accept a pull request.";
                                                    ["accept a pull request"] = {
                                                      ["$__text"] = "You accept a pull request.";
                                                      ["accept a pull request"] = {
                                                        ["$__text"] = "You accept a pull request.";
                                                        ["accept a pull request"] = {
                                                          ["$__text"] = "You accept a pull request.";
                                                          ["accept a pull request"] = {
                                                            ["$__text"] = "You accept a pull request.";
                                                            ["accept a pull request"] = {
                                                              ["$__text"] = "You accept a pull request.";
                                                              ["accept a pull request"] = {
                                                                ["$__text"] = "You accept a pull request.";
                                                                ["accept a pull request"] = {
                                                                  ["$__text"] = "You accept a pull request.";
                                                                  ["accept a pull request"] = {
                                                                    ["$__text"] = "You accept a pull request.";
                                                                    ["accept a pull request"] = {
                                                                      ["$__text"] = "You accept a pull request.";
                                                                      ["accept a pull request"] = {
                                                                        ["$__text"] = "You accept a pull request.";
                                                                        ["accept a pull request"] = {
                                                                          ["$__text"] = "You accept a pull request.";
                                                                          ["accept a pull request"] = {
                                                                            ["$__text"] = "You accept a pull request.";
                                                                            ["accept a pull request"] = {
                                                                              ["$__text"] = "You accept a pull request.";
                                                                              ["accept a pull request"] = {
                                                                                ["$__text"] = "You accept a pull request. There aren't any more. Perhaps the dwarves were right.";
                                                                              };
                                                                            };
                                                                          };
                                                                        };
                                                                      };
                                                                    };
                                                                  };
                                                                };
                                                              };
                                                            };
                                                          };
                                                        };
                                                      };
                                                    };
                                                  };
                                                };
                                              };
                                            };
                                          };
                                        };
                                        ["play doom"] = {
                                          ["$__text"] = "You play Doom.";
                                          ["shoot zombies"] = {
                                            ["$__text"] = "You shoot some zombies. Before you can make it to the next level, you're pwned by a cyberdemon.";
                                          };
                                        };
                                      };
                                      ["crawl right"] = {
                                        ["$__text"] = "It is dark.";
                                        ["continue"] = {
                                          ["$__text"] = "It is dark. You feel a sense of impending doom.";
                                          ["continue"] = {
                                            ["$__text"] = "You have been sporked by a grue.";
                                          };
                                          ["sing the doom song"] = {
                                            ["$__text"] = "Doom doom doom doom doom doom DOOM! Doom doom dooooom. Doom doom do-doomy doomy. You die.";
                                          };
                                        };
                                      };
                                      ["crawl up"] = {
                                        ["$__text"] = "Momentarily escaping gravity, you crawl up. You immmediately fall to your death.";
                                      };
                                      ["wait"] = {
                                        ["$__text"] = "You wait for another commit to heal your legs.";
                                      };
                                    };
                                  };
                                };
                              };
                            };
                          };
                          ["continue through city"] = {
                            ["$__text"] = "You can't. There is an elephant in the way.";
                            ["break it"] = {
                              ["$__text"] = "You break the elephant. Candy rains everywhere.";
                              ["eat candy"] = {
                                ["$__text"] = "You eat lots of candy, and lose the motivation to do anything else.";
                              };
                            };
                            ["buy it"] = {
                              ["$__text"] = "You buy the elephant, putting yourself deeply in debt, and dooming yourself to a life of financial stress.";
                            };
                            ["change it"] = {
                              ["$__text"] = "You change the elephant. You spend the rest of your life trying to convince the authorities that he's a changed man who doesn't need to be put away.";
                            };
                            ["charge it"] = {
                              ["$__text"] = "You charge the elephant and attempt to stab it with your spork. The elephant kills you.";
                            };
                            ["check it"] = {
                              ["$__text"] = "You check the elephant. Looks to be in pretty good condition. It kills you.";
                            };
                            ["cut it"] = {
                              ["$__text"] = "You cut the elephant. The elephant pulls out a gun and shoots you in the face. You die.";
                            };
                            ["earse it"] = {
                              ["$__text"] = "You erase the elephant. The elephant redraws itself and kills you.";
                            };
                            ["fix it"] = {
                              ["$__text"] = "You fix the elephant. Poor thing. It kills you in its rage.";
                            };
                            ["load it"] = {
                              ["$__text"] = "You load the elephant. The elephant is now loaded. The Spork Enforcer arrests you both for driving while intoxicated.";
                            };
                            ["mail it"] = {
                              ["$__text"] = "You mail the elephant to your parents. Hopefully they can find an use for it.";
                            };
                            ["name it"] = {
                              ["$__text"] = "You decide to name the elephant. What would you like to name it?";
                              ["bob"] = {
                                ["$__text"] = "Bob kills you.";
                              };
                              ["fred"] = {
                                ["$__text"] = "Fred kills you.";
                              };
                              ["tom"] = {
                                ["$__text"] = "Tom kills you.";
                              };
                            };
                            ["paste it"] = {
                              ["$__text"] = "You paste the elephant. What does that even mean? Anyway, it kills you.";
                            };
                            ["play it"] = {
                              ["$__text"] = "You play the elephant. No items, Fox only, Final Destination. The elephant is surprisingly good and kicks your ass.";
                            };
                            ["plug it"] = {
                              ["$__text"] = "You plug the elephant. Electricity now surges through the elephant.";
                              ["cool"] = {
                                ["$__text"] = "Indeed. The elephant kills you.";
                              };
                            };
                            ["point it"] = {
                              ["$__text"] = "You point the elephant. It now points toward the exit.";
                              ["leave"] = {
                                ["$__text"] = "You leave the labyrinth";
                              };
                            };
                            ["press it"] = {
                              ["$__text"] = "You press the elephant. It explodes. You are dead.";
                            };
                            ["rewrite it"] = {
                              ["$__text"] = "You rewrite the elephant. It is now a leopard.";
                              ["pet leopard"] = {
                                ["$__text"] = "You pet the leopard. It eats you.";
                              };
                              ["run"] = {
                                ["$__text"] = "You try to run away. The leopard eats you.";
                              };
                            };
                            ["save it"] = {
                              ["$__text"] = "You save the elephant. It is bitter and ungrateful. It kills you.";
                            };
                            ["snap it"] = {
                              ["$__text"] = "You snap the elephant and post the picture to your Facebook page. The picture goes viral and you spend the rest of your life pretending it matters.";
                            };
                            ["trash it"] = {
                              ["$__text"] = "You trash the elephant. Stupid litterers. Congratulations! You've saved the world!";
                            };
                            ["upgrade it"] = {
                              ["$__text"] = "You upgrade the elephant. It now has a spork cannon.";
                              ["upgrade it"] = {
                                ["$__text"] = "YYou upgrade the elephant. It now has armor plating.";
                                ["upgrade it"] = {
                                  ["$__text"] = "YYou upgrade the elephant. It now has armor plating.";
                                  ["upgrade it"] = {
                                    ["$__text"] = "You upgrade the elephant. It now has a neurally-activated temporal distortion field.";
                                    ["upgrade it"] = {
                                      ["$__text"] = "You upgrade the elephant. It now has a candy dispenser.";
                                      ["it is the time"] = {
                                        ["$__text"] = "t is time. Those dwarves, they were wrong. Today is the day.";
                                        ["ok"] = {
                                          ["$__text"] = "With the newly upgraded elephant by your side, you set out on a journey of galactic conquest.";
                                          ["conquer the labyrinth"] = {
                                            ["$__text"] = "Using the power of the elephant's spork cannon, you conquer the labyrinth.";
                                            ["conquer github"] = {
                                              ["$__text"] = "Using the power of the elephant's armor plating, you conquer GitHub.";
                                              ["conquer the world"] = {
                                                ["$__text"] = "Using the power of the elephant's neurally-activated temporal distortion field, you conquer the world.";
                                                ["conquer the galaxy"] = {
                                                  ["$__text"] = "Using the power of the elephant's candy dispenser, you conquer the galaxy.";
                                                  ["conquer the universe"] = {
                                                    ["$__text"] = "You attempt to conquer the universe. Unfortunately, you didn't upgrade your elephant enough, so you fail.";
                                                  };
                                                };
                                              };
                                            };
                                          };
                                        };
                                      };
                                    };
                                  };
                                };
                              };
                            };
                            ["use it"] = {
                              ["$__text"] = "You use the elephant. I'm not sure how, but you do. Then it kills you.";
                            };
                            ["work it"] = {
                              ["$__text"] = "You work the elephant. It demands to be paid wages. Will you pay it?";
                              ["no"] = {
                                ["$__text"] = "The elephant kills you and takes its money.";
                              };
                              ["yes"] = {
                                ["$__text"] = "You pay the elephant. You spend the rest of your life trying to pay off the debt.";
                              };
                            };
                            ["write it"] = {
                              ["$__text"] = "You write the elephant. It is very touched by your correspondence and would like to become friends. Will you befriend the elephant?";
                              ["no"] = {
                                ["$__text"] = "The elephant kills you.";
                              };
                              ["yes"] = {
                                ["$__text"] = "You befriend the elephant. Yay!";
                              };
                            };
                            ["zoom it"] = {
                              ["$__text"] = "You zoom the elephant. Vrooom! Nyeeuuurm! You crash into a wall and die.";
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
              ["Take the first door"] = {
                ["$__text"] = "An object in the middle of the room serves a clear reference to a meme.";
              };
              ["Take the second door"] = {
                ["$__text"] = "There is a bottomless pit in the middle of the room.";
                ["jump into pit"] = {
                  ["$__text"] = "You are falling.";
                  ["continue falling"] = {
                    ["$__text"] = "You are falling.";
                    ["continue falling"] = {
                      ["$__text"] = "You are falling.";
                      ["continue falling"] = {
                        ["$__text"] = "You are falling.";
                        ["continue falling"] = {
                          ["$__text"] = "You are falling.";
                          ["continue falling"] = {
                            ["$__text"] = "You are falling.";
                            ["continue falling"] = {
                              ["$__text"] = "You are falling.";
                              ["continue falling"] = {
                                ["$__text"] = "You are falling.";
                                ["continue falling"] = {
                                  ["$__text"] = "You are falling.";
                                  ["continue falling"] = {
                                    ["$__text"] = "You are falling.";
                                    ["continue falling"] = {
                                      ["$__text"] = "You are falling.";
                                      ["continue falling"] = {
                                        ["$__text"] = "You are falling.";
                                        ["continue falling"] = {
                                          ["$__text"] = "You are falling.";
                                          ["continue falling"] = {
                                            ["$__text"] = "You are falling.";
                                            ["continue falling"] = {
                                              ["$__text"] = "You are falling.";
                                              ["continue falling"] = {
                                                ["$__text"] = "You are falling.";
                                                ["continue falling"] = {
                                                  ["$__text"] = "You are falling.";
                                                  ["continue falling"] = {
                                                    ["$__text"] = "You are falling.";
                                                    ["continue falling"] = {
                                                      ["$__text"] = "You are falling.";
                                                      ["continue falling"] = {
                                                        ["$__text"] = "You are falling.";
                                                        ["continue falling"] = {
                                                          ["$__text"] = "You are falling.";
                                                          ["continue falling"] = {
                                                            ["$__text"] = "You are falling.";
                                                            ["continue falling"] = {
                                                              ["$__text"] = "You are falling.";
                                                              ["continue falling"] = {
                                                                ["$__text"] = "You are falling.";
                                                                ["continue falling"] = {
                                                                  ["$__text"] = "You reached the end of the labyrinth! Congratulations!";
                                                                };
                                                              };
                                                            };
                                                          };
                                                        };
                                                      };
                                                    };
                                                  };
                                                };
                                              };
                                            };
                                          };
                                        };
                                      };
                                    };
                                  };
                                };
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
              ["Take the third door"] = {
                ["$__text"] = "You see it briefly before the end. Its song is beautiful. All too soon, it is over.";
                ["ok"] = {
                  ["$__text"] = "You can go right or left";
                  ["left"] = {
                    ["$__text"] = "It is a dead end. You notice that the sky is a particularily tepid shade of blue.";
                  };
                  ["right"] = {
                    ["$__text"] = "You walk into an amusment park parking lot. There is no hope of escape.";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

function draw_it()
  local w, h = term.getSize()
  local sel_width = w - 3
  
  local current_path = table.concat(path, "/") --""
  --for k, v in ipairs(path) do
  --  current_path = current_path .. "/" .. v
  --end
  
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1,1)
  print(string.sub(current_path, -w))
  print()
  print(current_text)
  print()
  
  local draw_options = {}
  local sel_line, sel_size = 1, 1
  local x, y = term.getCursorPos()
  local skip = 0
  if #all_options > (h - y) then
    if selection > ((h - y) / 2) then
      skip = math.min(selection - ((h - y) / 2), #all_options - (h - y) - 1)
    end
  end
  
  local curr_line = ""
  for k, v in ipairs(all_options) do
    if selection == k then
      curr_line = "> "
    else
      curr_line = "- "
    end
    
    for i in string.gmatch(v, "%S+") do
      if i:len() > sel_width then
        draw_options[#draw_options + 1] = curr_line
        curr_line = "   "
        while i:len() > sel_width do
          curr_line = curr_line .. i:sub(1, sel_width)
          i = i:sub(sel_width)
          draw_options[#draw_options + 1] = curr_line
          curr_line = "   "
        end
      end
      
      if i:len() > (sel_width - #curr_line) then
        draw_options[#draw_options + 1] = curr_line
        curr_line = "   "
      end
      curr_line = curr_line .. i
      
      if (sel_width - #curr_line) <= 1 then
        draw_options[#draw_options + 1] = curr_line
        curr_line = "   "
      else
        curr_line = curr_line .. " "
      end
      
      
    end
    if draw_options[#draw_options] ~= curr_line then
      draw_options[#draw_options + 1] = curr_line
    end
  end
  
  for k, v in ipairs(draw_options) do
    if skip == 0 then
      local x, y = term.getCursorPos()
      if v:sub(1,1) == ">" then
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.white)
      elseif v:sub(1,1) == "-" then
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
      end
      term.write(v)
      -- Go all the way to the end of the line
      term.write(string.rep(" ", w - #v))
      term.setCursorPos(1, y + 1)
    else
      skip = skip - 1
    end
  end
end

function get_info_from_current_room()
  local curr_room = laby
  for k, v in ipairs(path) do
    curr_room = curr_room[v]
  end
  
  current_text = curr_room["$__text"] or ""
  allow_back = laby["$__default_back"]
  if curr_room["$__no_back"] or curr_room["$__back"] then
    allow_back = not curr_room["$__no_back"]
  end
  allow_restart = curr_room["$__restart"]
  
  if curr_room == laby then
    allow_back = false -- You cant go any back
  end
  
  options = {}
  all_options = {}
  
  for k, v in pairs(curr_room) do
    if tostring(k):sub(1,3) ~= "$__" then
      options[#options + 1] = k
      all_options[#all_options + 1] = k
    end
  end
  
  if allow_back then
    all_options[#all_options + 1] = "Back"
  end
  
  if allow_restart then
    all_options[#all_options + 1] = "Restart"
  end
  
  selection = 1
end

local arg = {...} -- In vanilla lua, this table already exists
if arg[1] == nil then
  print("Usage: labyrinth <file> - Use \"default\" use the internial one")
  print("Terminate to quit, UP/DOWN ARROW to select the option, ENTER to do it")
elseif arg[1] == "default" then
  laby = default_labyrinth
  running = true
else
  -- TODO: Implement a reader and just do it.
  print("TODO - Nothing here yet")
end

if running then
  get_info_from_current_room()
  while running do
    if redraw then
      draw_it()
      redraw = false
    end
    local ev, p1, p2, p3 = os.pullEventRaw()
    if ev == "terminate" then
      running = false
      break
    elseif ev == "key" then
      if p1 == 200 then -- UpArrow
        redraw = true
        if selection == 1 then
          selection = #all_options
        else
          selection = selection - 1
        end
      elseif p1 == 208 then -- DownArrow
        redraw = true
        if selection == #all_options then
          selection = 1
        else
          selection = selection + 1
        end
      elseif p1 == 28 then -- Enter
        redraw = true
        if selection > #options then
          if allow_restart and selection == #all_options then
            path = {}
          elseif allow_back and ((allow_restart and selection == (#all_options - 1)) or (not allow_restart and selection == #all_options)) then
            path[#path] = nil
          end
        else
          path[#path + 1] = all_options[selection]
        end
        get_info_from_current_room()
      elseif p1 == 14 then
        if cheats["back"] then
          path[#path] = nil
          get_info_from_current_room()
          redraw = true
        end
      end
    elseif ev == "term_resize" then
      redraw = true
    end
  end
  
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1, 1)
  print(laby["$__terminate"] or "You can't take it anymore and terminated yourself. THE END.")
end