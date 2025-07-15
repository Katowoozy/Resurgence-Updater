def convertSaveFolder
  folder = RTP.getSaveFolder
  # load in data needed for conversions
  File.open("Scripts/ConversionClasses.rb") { |f| eval(f.read) }
  # IDs are not compiled; this grabs them directly from their PBS hash
  File.open("Scripts/" + GAMEFOLDER + "/montext.rb") { |f| eval(f.read) }
  File.open("Scripts/" + GAMEFOLDER + "/movetext.rb") { |f| eval(f.read) }
  File.open("Scripts/" + GAMEFOLDER + "/itemtext.rb") { |f| eval(f.read) }
  File.open("Scripts/" + GAMEFOLDER + "/abiltext.rb") { |f| eval(f.read) }
  # errors here are terrifying and we like safety
  Dir.mkdir(folder + "Conversion Backup") unless (File.exists?(folder + "Conversion Backup"))
  filecount = Dir.new(folder).count { |file| file.end_with?(".rxdata") }
  conversioncount = 0
  return if filecount == 0

  backupSaveFiles(folder)
  convertSettings(folder)

  Dir.foreach(folder) do |filename|
    next if filename == '.' || filename == '..' || filename == "Conversion Backup" || !filename.end_with?(".rxdata")
    next if filename != "Game.rxdata" && !(filename =~ /Game_\d+\.rxdata/) && !(filename =~ /Anna's Wish Game(_\d+)?\.rxdata/)

    conversioncount += 1
    newsave = {}
    puts filename
    dir = folder + filename
    begin # protection for corrupt saves
      File.open(dir) { |f|
        trainer = Marshal.load(f)
        if trainer.is_a?(Hash) # if it's a hash, then this save has already been converted.
          conversioncount -= 1
          next
        end
        newsave[:playtime]   = Marshal.load(f)
        newsave[:system]     = Marshal.load(f)
        Marshal.load(f) # dropping pokemonsystem in favor of clientdata
        newsave[:map_id]    = Marshal.load(f) # Current map id no longer needed
        # REJUV SILLY MAPS GO HERE TO CATCH
        newsave[:switches]  = Marshal.load(f) # Why does removing these break shit
        newsave[:variable]  = Marshal.load(f)
        if Reborn && newsave[:switches][1361] # randomizer
          newsave[:switches][1361] = false
          newsave[:variable][565] = 0
          newsave[:variable][566] = 0
          newsave[:variable][566] = 0
        end
        newsave[:self_switches] = Marshal.load(f)
        newsave[:game_screen] = Marshal.load(f)
        weathertype = newsave[:game_screen].weather_type
        if weathertype != 0
          weatherdur = newsave[:game_screen].weather_duration
          weatherpow = 0
          maxtarget = newsave[:game_screen].weather_max_target
          weatherpow = (maxtarget / 4.0) - 1 if maxtarget
          newsave[:game_screen].weather(weathertype, weatherpow, weatherdur)
        end
        Marshal.load(f) # killing mapfactory????
        newsave[:game_player] = Marshal.load(f)
        global = Marshal.load(f)
        newsave[:PokemonMap] = Marshal.load(f)
        bag = Marshal.load(f)
        storage = Marshal.load(f)
        achievements = Marshal.load(f) if Rejuv

        bag = collectItems(bag, global.pcItemStorage)
        global.pcItemStorage = nil if global.pcItemStorage
        trainer = convertTrainer(trainer)
        storage = convertStorage(storage)
        trainer = convertDex(trainer, storage)
        global = convertGlobal(global, storage)
        newsave[:PokemonBag] = bag
        newsave[:Trainer] = trainer
        newsave[:Trainer].achievements = achievementConvert(achievements) if Rejuv
        newsave[:PokemonStorage] = storage
        newsave[:PokemonGlobal] = global

        # print "stop"
        save_data(newsave, dir)
      }
      percent = (100.0 * conversioncount / filecount).round
      System.set_window_title("#{percent}\% converted...")
    rescue
      puts "Save '#{dir}' is corrupt!"
      filecount -= 1
      next
    end
  end
  System.set_window_title(GAMETITLE)

  if defined?(DiscordAppID) && DiscordAppID && !$joiplay && $Settings.discordRPC == 1
    msgwindow = Kernel.pbCreateMessageWindow
    Kernel.pbMessageDisplay(msgwindow, _INTL("This game has Discord integration, which shares in-game activity updates on your status. You can turn this off in Options.", "0"))
    Kernel.pbDisposeMessageWindow(msgwindow)
  end
end

def backupSaveFiles(folder)
  Dir.mkdir(folder + "Conversion Backup") unless (File.exists?(folder + "Conversion Backup"))
  Dir.foreach(folder) do |filename|
    next if !filename.end_with?(".rxdata")

    File.open(folder + filename, "rb") do |input|
      File.open(folder + "Conversion Backup" + "/" + filename, "wb") do |output|
        while buff = input.read(4096)
          output.write(buff)
        end
      end
    end
  end
end

def convertSettings(folder)
  if File.exists?(RTP.getSaveFileName("Game.dat"))
    File.open(RTP.getSaveFileName("Game.dat")) { |f|
      $oldsettings = Marshal.load(f)
      $Settings = $oldsettings[:settings] if !$oldsettings[:settings].nil?
      $Settings.fixMissingValues
      pbSetResizeFactor($Settings.screensize)
    }
  end
end

def collectItems(bag, pc)
  newbag = PokemonBag.new()
  for pocket in bag.pockets # get all of the items out of the bag
    next if pocket == nil

    for item in pocket # get all the items in a pocket
      next if item == nil

      itemsym = nil
      item[0] = itemfixer(item[0]) if Desolation
      for i in ITEMHASH.keys # convert pocket item to symbol
        if ITEMHASH[i][:ID] == item[0]
          itemsym = i
          break
        end
      end
      newbag.pbStoreItem(itemsym, item[1]) # it's basically just a discount hash.
    end
  end
  return newbag if !pc # if you don't have an item pc, you're free to go.

  for item in 0...pc.length # pc is a little less complicated.
    itemsym = nil
    for i in ITEMHASH.keys # convert pocket item to symbol
      if ITEMHASH[i][:ID] == item[0]
        itemsym = i
        break
      end
    end
    newbag.pbStoreItem(itemsym, item[1]) # it's basically just a discount hash.
  end
  return newbag
end

def convertTrainer(trainer)
  newparty = []
  for mon in trainer.party
    newparty.push(convertMon(mon))
  end
  trainer.party = newparty
  if trainer.trainertype.is_a?(Integer)
    $cache.trainertypes.each do |sym, data|
      trainer.trainertype = sym if data.checkFlag?(:ID) == trainer.trainertype
    end
    # trainer.trainertype = $cache.trainertypes.keys[0] if trainer.trainertype.is_a?(Integer)
  end
  return trainer
end

def convertStorage(storage)
  for box in 0...storage.maxBoxes
    for index in 0...storage[box].length
      mon = storage[box, index]
      next if !mon

      storage[box, index] = convertMon(mon)
    end
  end
  storage.upTotalBoxes(STORAGEBOXES)
  return storage
end

def convertDex(trainer, storage)
  # newtrainer = deep_copy(trainer)
  if !trainer.pokedex.nil?
    puts "Converting dex..."
    time = Time.now
    newdex = Pokedex.new()
    newdex.initDexList()
    for id in 1..newdex.dexList.length
      species = $cache.pkmn.keys[id - 1]
      newdex.dexList[species][:seen?] = trainer.seen[id]
      newdex.dexList[species][:owned?] = trainer.owned[id]
      newdex.dexList[species][:shadowCaught?] = trainer.shadowcaught[id]
      if trainer.owned[id]
        newdex.dexList[species][:gender].each { |gender, v| newdex.dexList[species][:gender][gender] = true }
        newdex.dexList[species][:forms].each { |form, v| newdex.dexList[species][:forms][form] = true }
      end
      newdex.dexList[species][:lastSeen] = {
        gender: newdex.dexList[species][:gender].keys[0],
        form: newdex.dexList[species][:forms].keys[0],
        shiny: false,
      }
    end
    trainer.party.each { |mon| newdex.dexList[mon.species][:shinySeen?] = mon.isShiny? }
    for boxes in storage.boxes
      for mon in boxes
        if mon != nil
          newdex.dexList[mon.species][:shinySeen?] = mon.isShiny?
        end
      end
    end
    newdex.canViewDex = trainer.pokedex
    trainer.pokedex = newdex
    trainer.seen = nil
    trainer.owned = nil
    trainer.shadowcaught = nil
    trainer.formseen = nil
    trainer.formlastseen = nil
    puts "Done! - Took #{Time.now - time} sec"
  end
  return trainer
end

def convertGlobal(global, storage)
  if global.daycare[0][0]
    newmon = convertMon(global.daycare[0][0])
    global.daycare[0][0] = newmon
  end
  if global.daycare[1][0]
    newmon = convertMon(global.daycare[1][0])
    global.daycare[1][0] = newmon
  end
  if global.hallOfFame
    for i in 0...global.hallOfFame.size
      for j in 0...global.hallOfFame[i].size
        newmon = convertMon(global.hallOfFame[i][j])
        global.hallOfFame[i][j] = newmon
      end
    end
  end
  global.dependentEvents = [] if !global.dependentEvents
  global.hallOfFame = [] if !global.hallOfFame
  global.hallOfFameLastNumber = 0 if !global.hallOfFameLastNumber
  if !global.purifyChamber
    global.purifyChamber = PurifyChamber.new()
  else
    for i in 0...10
      setList = global.purifyChamber.setList(i)
      if setList.length > 0
        for j in 0...setList.length
          newmon = convertMon(setList[j])
          storage.pbStoreCaught(newmon)
        end
      end
      shadow = global.purifyChamber.getShadow(i)
      if !shadow.nil?
        newmon = convertMon(shadow)
        storage.pbStoreCaught(newmon)
        global.purifyChamber.setShadow(i, nil)
      end
      j = setList.length
      while j > -1
        global.purifyChamber.insertAt(i, j, nil)
        j -= 1
      end
    end
  end
  if global.partner
    $cache.trainertypes.each { |sym, data|
      if data.checkFlag?(:ID) == global.partner[0]
        global.partner[0] = data.ttype
        break
      end
    }
    global.partner[3].each { |mon|
      mon = convertMon(mon)
    }
    if global.partner[4]
      global.partner[4].each { |item|
        for i in $cache.items.keys
          itemdata = $cache.items[i]
          if itemdata.checkFlag?(:ID) == item
            item = i
            break
          end
        end
      }
    end
  end
  return global
end

def convertMon(mon)
  for i in MONHASH.keys
    formname = MONHASH[i].keys[0]
    if MONHASH[i][formname][:dexnum] == mon.species
      mon.species = i
      break
    end
  end
  newmoves = []
  for move in mon.moves
    for i in MOVEHASH.keys
      if MOVEHASH[i][:ID] == move.id
        newmove = PBMove.new(i)
        newmove.pp = move.pp
        newmove.ppup = move.ppup
        newmoves.push(newmove)
        break
      end
    end
  end
  mon.moves = newmoves
  firstmoves = []
  if !mon.firstmoves.nil?
    for move in mon.firstmoves
      for j in MOVEHASH.keys
        if MOVEHASH[j][:ID] == move
          newmove = PBMove.new(j)
          firstmoves.push(newmove.move)
          break
        end
      end
    end
    mon.firstmoves = firstmoves
  end
  if mon.shadowmoves
    newShadows = []
    for move in mon.shadowmoves
      if move == 0
        newShadows.push(0)
        next
      end
      for i in MOVEHASH.keys
        if MOVEHASH[i][:ID] == move
          newShadows.push(i)
          break
        end
      end
    end
    mon.shadowmoves = newShadows
  end
  mon.item = nil if mon.item == 0
  mon.item = itemfixer(mon.item) if Desolation
  mon.item = zcrystalfix(mon.item) if !Desolation
  for i in ITEMHASH.keys
    if ITEMHASH[i][:ID] == mon.item
      mon.item = i
      break
    end
  end
  mon.initZmoves(mon.item, true) if pbIsZCrystal?(mon.item)
  for i in BallHandlers::BallTypes.keys
    if i == mon.ballused
      mon.ballused = BallHandlers::BallTypes[i]
      break
    end
  end
  mon.level = PBExp.levelFromExperience(mon.exp, mon.growthrate)
  if mon.level == 0
    mon.level = 1
    mon.exp = PBExp.startExperience(1, mon.growthrate)
  end
  mon.form = 0 if !mon.form
  mon.form = formfixer(mon) if Rejuv
  speed = mon.iv.delete_at(3)
  mon.iv.push(speed)
  speed = mon.ev.delete_at(3)
  mon.ev.push(speed)
  mon.setAbility(mon.personalID % 3)
  if mon.instance_variable_defined?(:@abilityflag)
    mon.setAbility(mon.instance_variable_get(:@abilityflag))
  end
  if !mon.getAbilityList.include?(mon.ability)
    mon.setAbility(mon.getAbilityList[mon.personalID & mon.getAbilityList.length - 1])
  end
  mon.ability == :AURABREAK if mon.species == :ZYGARDE
  mon.setNature($cache.natures.keys[mon.natureflag]) if mon.natureflag != nil
  mon.nature = $cache.natures.keys[mon.personalID % 25]
  statuses = { 1 => :SLEEP, 2 => :POISON, 3 => :BURN, 4 => :PARALYSIS, 5 => :FROSTBITE }
  mon.status = statuses[mon.status]
  mon.fused = convertMon(mon.fused) if mon.fused.is_a?(PokeBattle_Pokemon)
  mon.hptype = $cache.types.keys[mon.hptype] if mon.hptype != nil
  return mon
end

def tempConvertNatures
  for mon in $Trainer.party
    next if mon.nature.is_a?(Symbol)

    mon.setNature($cache.natures.keys[mon.natureflag]) if mon.natureflag != nil
    mon.nature = $cache.natures.keys[mon.personalID % 25]
  end
  for box in 0...$PokemonStorage.maxBoxes
    for index in 0...$PokemonStorage[box].length
      mon = $PokemonStorage[box, index]
      next if !mon
      next if mon.nature.is_a?(Symbol)

      mon.setNature($cache.natures.keys[mon.natureflag]) if mon.natureflag != nil
      mon.nature = $cache.natures.keys[mon.personalID % 25]
    end
  end
end

def zcrystalfix(item)
  crystals = [719, 721, 723, 725, 727, 729, 731, 733, 735, 737, 739, 741, 743, 745, 747, 749, 751, 753, 755, 757, 759, 761, 763, 765, 767, 769, 771, 773]
  crystals += [782, 784, 786, 788, 790, 792] if Reborn
  crystals += [843, 845, 847, 849, 851, 853] if Rejuv
  return item - 1 if crystals.include?(item)
  return nil if item == 1044 && Rejuv

  return item
end

def formfixer(mon)
  if mon.species == :LAPRAS
    return 1 if mon.form == 2

    return mon.form
  elsif mon.species == :AMPHAROS
    return 1 if mon.form == 2

    return mon.form
  elsif mon.species == :TOXTRICITY
    return 2 if mon.form == 4

    return mon.form
  else
    return mon.form
  end
end

def powerconstructhunt(storage, trainerparty, daycare)
  for box in 0...storage.maxBoxes
    for index in 0...storage[box].length
      mon = storage[box, index]
      next if !mon

      mon.ability = :AURABREAK if mon.species == :ZYGARDE
    end
  end
  for mon in trainerparty
    mon.ability = :AURABREAK if mon.species == :ZYGARDE
  end
  if daycare[0][0]
    daycare[0][0].ability = :AURABREAK if daycare[0][0].species == :ZYGARDE
  end
  if daycare[1][0]
    daycare[1][0].ability = :AURABREAK if daycare[1][0].species == :ZYGARDE
  end
end