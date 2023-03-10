# Changelog

## Zelda Mystery of Solarus DX 1.13.0 (in progress)

* Add thumbnail.

## Zelda Mystery of Solarus DX 1.12.3 (2021-04-06)

* Add Brazilian Portuguese translation (thanks Lucas Yamashita) (#140).

## Zelda Mystery of Solarus DX 1.12.2 (2019-08-16)

* Fix some scrolling teletransporters broken in Solarus 1.6.1.

## Zelda Mystery of Solarus DX 1.12.1 (2019-08-10)

* Fix typo in English texts (#128).
* Fix mistakes in German texts (#137).
* Fix deprecated function calls since Solarus 1.6 (#131).

## Zelda Mystery of Solarus DX 1.12.0 (2018-12-22)

* Upgrade to Solarus 1.6.
* Add the Solarus team logo.
* Change the sound of the Solarus logo.
* Fix typos in French dialogs (thanks Renkineko).

## Zelda Mystery of Solarus DX 1.11.0 (2016-07-27)

* Upgrade to Solarus 1.5.
* Fix wrong layer when leaving dungeon 10.
* Dungeon 2: Fix sound played twice when activating the statues.
* Dungeon 9: fix getting back to room entrance when touching spikes.
* English dialogs: rename Pegasus Shoes to Pegasus Boots.

## Zelda Mystery of Solarus DX 1.10.3 (2015-12-20)

* Fix Italian dialogs exceeding the dialog box (thanks Marco).
* Fix game-over stopped sometimes using a workaround (#87).

## Zelda Mystery of Solarus DX 1.10.2 (2015-11-22)

* Upgrade to Solarus 1.4.5.
* Add Italian translation (thanks Marco).
* Make fairies play a sound when restoring life even when already full (#101).
* Fix dialog cursor drawn at wrong position after successive questions (#105).
* Dungeon 1: fix unintentional extra difficulty with block alignment (#102).
* Dungeon 3: fix enemy entering mini-boss room (#107).
* Dungeon 9: fix spikes sending back to wrong room (#108).
* Dungeon 10: fix evil tiles door not opening sometimes (#94).
* End screen: fix freezing the hero (#109).

## Zelda Mystery of Solarus DX 1.10.1 (2015-05-09)

* Upgrade to Solarus 1.4.1.

## Zelda Mystery of Solarus DX 1.10.0 (2015-05-02)

* Upgrade to Solarus 1.4.0.
* Fix a minor tile issue in dungeon 8 entrance.
* Fix the feather dialog that could be skipped in some languages.
* Fix empty line in English dialog describing a bottle with water.
* Fix empty buttons in savegame menu when changing language (#90).
* Fix translation errors of two items in German (#98).
* Dungeon 5: fix a missing door on the minimap (#99).
* Dungeon 9: don't allow to skip the boss hint dialog (#93).

## Zelda Mystery of Solarus DX 1.9.0 (2014-08-21)

* Use Solarus 1.3.0.
* New world minimap. By Neovyse.
* Make cmake paths more modifiable. By hasufell.
* Fix direction of vertical movement on joypad in menus (#85). By xethm55.
* Clarify license of some files.

## Zelda Mystery of Solarus DX 1.8.0 (2014-05-06)

* Use solarus 1.2.0.
* Replace fixed8.fon by a TTF font due to an SDL2 regression (#59).
* Switch fullscreen also with F11.
* Dungeon 3 5F: fix falling too early in the hole due to incorrect layers.

## Zelda Mystery of Solarus DX 1.7.1 (2013-12-01)

* Use Solarus 1.1.1.
* Fix the heart meter not updated until the first save/reload (#67).
* Fix wrong teletransportation in Billy's cave after falling in a hole (#66).
* Fix the debugging console no longer working after using F1, F2 or F3.

## Zelda Mystery of Solarus DX 1.7.0 (2013-10-13)

* Use solarus 1.1.0.
* Add simplified Chinese and traditional Chinese translations (beta).
* Replace .spc musics by .it ones (much faster) (#17).
* Add an animated Solarus logo from Maxs (#57).
* Fix savegames freshly created with Solarus 0.9 and never run yet.
* Fix a slight alignment issue with the hurt animation of the hero.
* Fix a small breach in dungeon 9 4F in the timed chest room (#4).
* Fix easy infinite rupees in the waterfall cave (#13).
* Fix low health beeping playing at final screen (#56).
* Add a teletransporter from south lake to the cave under the waterfall (#10).
* Dungeon 7 boss: the player could get stuck in the boss room (#6).
* Dungeon 7 boss: change the misleading hurt sound of the tail (#7).
* Dungeon 7: help the player be aligned correctly to obtain the boss key (#8).
* Dungeon 3 2F: fix two switches that disappeared when activating them.
* Dungeon 2 boss: fix tile disappearing issue (#14).
* Dungeon 9 2F: fix a minor graphical issue.

## Zelda Mystery of Solarus DX 1.6.2 (2013-06-25)

* Use solarus 1.0.4.
* Fix line errors in English dialogs.

## Zelda Mystery of Solarus DX 1.6.1 (2013-06-25)

* Use solarus 1.0.3.

## Zelda Mystery of Solarus DX 1.6 (2013-06-22)

* Use solarus 1.0.2.
* Improve the English translation.
* New title screen from Neovyse (#45).
* Fix a typo in French dialogs.
* Fix a door bug that could get the hero stuck in empty rooms.
* Fix saving the state of Billy's door.
* Dungeon 1: keep the final door open when coming back in the boss room.
* Dungeon 7 2F: save the north-west torches.
* Savegames menu: the joypad was not working to delete a savegame.
* Dungeon 10 B1: fix a cauldron the hero could walk on (#20).
* Rupee house: don't let the player to get the piece of heart with the sword.
* Dungeon 6 2F: move crystal blocks to avoid a possible breach.
* Outside world B3: fix a minor tile error (#12).
* Dungeon 8 B1: fix a minor tile error (#2).
* Dungeon 8 B3: fix a minor tile error.

## Zelda Mystery of Solarus DX 1.5.2 (2013-05-08)

* Use solarus 0.9.3.
* German dialogs available.
* Castle 1F: fix NPCs possibly overlapping the hero.
* West mountains cave: fix a chest possibly overlapping the hero.
* Fix wrong displaying of a question in French dialogs.
* Fix three typos in French dialogs (thanks Stella).
* Improve the English translation (thanks Rypervenche).
* Fix a wrong empty line in English dialogs.
* Dungeon 5: fix an error the Spanish translation (thanks Joan).
* Fix the CMake script that creates the zip archive (#1).

## Zelda Mystery of Solarus DX 1.5.1 (2012-05-20)

* Spanish dialogs available (beta)
* English dialogs: fix dialogs with questions
* English dialogs: various improvements
* Dungeon 10: the hero could land in a wall when falling into a hole
* Dungeon 10: help the player a little bit more with the weak wall
* Dungeon 10: change the location where a key appears
* Dungeon 10: fix minor mapping errors
* Dungeons 7 and 10: fix blue flames in the boss
* Dungeon 5 B1: give bombs to make sure the hero can pass the weak walls
* Dungeon 5 2F: move the hint stone to the room of the corresponding puzzle
* Dungeon 5 2F: two enemies could be stopped by strange invisible walls
* Dungeon 6 3F: really fix the breach
* Savegame variable 0 was used twice (no consequence)
* Always set the variant of _none and _random treasures to 1

## Zelda Mystery of Solarus DX 1.5.0 (2012-04-03)

* Use solarus 0.9.2
* English translation available
* Dungeon 5: the piece of heart could be obtained very easily with the sword
* Dungeon 5: a black guard was never seeing the hero

## Zelda Mystery of Solarus DX 1.4.1 (2012-02-18)

* Dungeon 5: fix wrong coordinates of two blocks saved

## Zelda Mystery of Solarus DX 1.4 (2012-02-12)

* Use solarus-0.9.1
* The Pegasus Shoes can now be used with the action key
* New end screen
* Dungeon 1: restart the boss minillosaurs after they are hurt
* Dungeon 9: the player could be stuck if using a bomb on a crystal
* Dungeon 9: the player could be stuck because of an incorrect jump length
* Dungeon 7: the player could be stuck in a room if he had no key
* West mountains cave 1F: the player could be stuck if a door was closed
* Dungeon 10: a part of the main puzzle could be skipped because of blocks
* Dungeon 1: the miniboss could be displayed under a wall
* Don't make enemies follow the hero if they are on a different layer
* Dungeon 9 boss: don't create more than one stone at a time
* Potion shop: fix the coordinates on the minimap
* Inferno river maze: fix the coordinates on the minimap
* Dungeon 8 B4: the two switches could remain activated when leaving them
* Dungeon 8 B4: the hero could be stuck if the door was closed
* Dungeon 8 B2: a staircase was missing on the minimap
* Change the color of shallow water and grass below the hero in the dark world
* Change the color of the splash sprites when plunging into lava
* Pikes: vertical pikes failed to move if the hero was too close
* Dungeon 4 boss: a petal was harder to reach once others were killed
* Dungeon 4 boss: keep the door to the final room open after the boss
* Dungeon 4: replace a boring and buggy room by a room with evil tiles
* Dungeon 4: reorganize chests to make the 4 chests puzzle clearer
* Dungeon 1: make the blocks puzzle shorter and add a chest with a croissant
* Dungeon 5: move the first small key to the basements
* Dungeon 5: set a random configuration of doors open in the prison
* Dungeon 5: move the feather puzzle to reduce the distance of blocks
* Dungeon 7: save the switches code
* Dungeon 9: a miniboss door was strangely made closed again
* Dungeon 10: make some enemies give bombs
* Fix a typo for blue potions in the inventory
* Fix the name of dungeon 6 in the minimap
* Dungeon 9 boss: make a different sound when immobilized
* Fairy cave: don't force the player do the blocks puzzle twice
* Change how the hero is forced to finish dungeon 2 before starting dungeon 3
* Smith cave: change the price of the sword (75 instead of 80)
* Various minor improvements

## Zelda Mystery of Solarus DX 1.3 (2011-12-23)

* Use solarus-0.9.0 (changelogs of solarus and zsdx will now be separated)
* Dungeon 7: fix a possible crash with statues and pikes
* Make sure swords are obtained in the correct order
* Don't play the sound of pikes too frequently when they don't have much space
* After the boss of dungeon 10, re-enable enemies of the map

## Zelda Mystery of Solarus DX 1.2 (2011-12-21)

* Dungeon 9: fix a crash with two enemies that appear on a platform
* Attempt to fix a crash with mummies by removing a useless and buggy feature
* Dungeon 10: let hero to go back from the roof after killing the boss
* Dungeon 6: it was possible to bypass a part of the dungeon
* Dungeon 1: fix the fixed minillosaur eggs
* Small map improvements

## Zelda Mystery of Solarus DX 1.1 (2011-12-19)

* Fix a crash when jumping from grass into a hole
* Fix a possible crash when buying potions
* Fix a memory leak with shop items
* Dungeon 9: two doors were traversable
* Dungeon 3: the boss could become inactive after a while
* Dungeon 7: some flames of the boss stayed fixed
* Adjust the difficulty of some bosses
* West mountains cave: the hero could be stuck after falling
* Dungeon 8: open a door
* Dungeon 8 minimap: remove an unexisting door
* Minor map improvements
* Update copyright info

## Zelda Mystery of Solarus DX 1.0 (2011-12-16)

* Initial release of Zelda Mystery of Solarus DX
