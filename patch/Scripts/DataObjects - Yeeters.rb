def dumpDataHashes
  File.open("Scripts/" + GAMEFOLDER + "/PBSpecies.rb") { |f| eval(f.read) }
  File.open("Scripts/" + GAMEFOLDER + "/PBTrainers.rb") { |f| eval(f.read) }
  File.open("Scripts/" + GAMEFOLDER + "/PBAbilities.rb") { |f| eval(f.read) }
  File.open("Scripts/" + GAMEFOLDER + "/PBItems.rb") { |f| eval(f.read) }
  File.open("Scripts/" + GAMEFOLDER + "/PBTypes.rb") { |f| eval(f.read) }
  File.open("Scripts/" + GAMEFOLDER + "/PBMoves.rb") { |f| eval(f.read) }
  itemDump
  moveDump
  encDump
  abilDump
  metaConvert
  trainTypesDump
  monDump
  pbCompileTrainers
  dumpTeams
end

def abilDump
  exporttext = "ABILHASH = {\n"
  for i in 1...234
    exporttext += ":#{getConstantName(PBAbilities, i)} => {\n"
    exporttext += "  :ID => #{i},\n"
    exporttext += "  :name => \"#{pbGetMessage(MessageTypes::Abilities, i)}\",\n" # kill this
    exporttext += "  :desc => \"#{pbGetMessage(MessageTypes::AbilityDescs, i)}\"\n" # kill this
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/abiltext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def metaDump
  metadata = $cache.metadata
  exporttext = "METAHASH = {\n"
  exporttext += ":home => #{metadata[:home].inspect},\n"
  exporttext += ":TrainerVictory => \"#{metadata[:TrainerVictory]}\",\n"
  exporttext += ":WildVictory => \"#{metadata[:WildVictory]}\",\n"
  exporttext += ":TrainerBattle => \"#{metadata[:TrainerBattle]}\",\n"
  exporttext += ":WildBattle => \"#{metadata[:WildBattle]}\",\n"
  exporttext += ":Surf => \"#{metadata[:Surf]}\",\n"
  exporttext += ":LavaSurf => \"#{metadata[:LavaSurf]}\",\n"
  exporttext += ":Bicycle => \"#{metadata[:Bicycle]}\",\n\n"
  for i in 0...$cache.metadata[:Players].length
    player = $cache.metadata[:Players][i]
    exporttext += ":player#{i + 1} => {\n"
    exporttext += "  :tclass => :#{player[:tclass]},\n"
    exporttext += "  #sprites,\n"
    exporttext += "  :walk => \"#{player[:walk]}\",\n" if player[:walk] != ""
    exporttext += "  :run => \"#{player[:run]}\",\n" if player[:run] != ""
    exporttext += "  :bike => \"#{player[:bike]}\",\n" if player[:bike] != ""
    exporttext += "  :surf => \"#{player[:surf]}\",\n" if player[:surf] != ""
    exporttext += "  :dive => \"#{player[:dive]}\",\n" if player[:dive] != ""
    exporttext += "  :fishing => \"#{player[:fishing]}\",\n" if player[:fishing] != ""
    exporttext += "  :surffish => \"#{player[:surffish]}\",\n" if player[:surffish] != ""
    exporttext += "},\n\n"
  end
  for i in 1...$cache.mapdata.length
    puts "Dumping map ##{i}"
    map = $cache.mapdata[i]
    if map.nil?
      exporttext += "\##{$cache.mapinfos[i].name}\n"
      exporttext += "#{i} => {}, \n\n"
      next
    end
    exporttext += "\##{$cache.mapinfos[i].name}\n"
    exporttext += "#{i} => { \n"
    exporttext += "  :HealingSpot => #{map.HealingSpot.inspect},\n" if map.HealingSpot
    exporttext += "  :MapPosition => #{convertMapPos(map.MapPosition).inspect},\n" if map.MapPosition
    exporttext += "  :Outdoor => #{map.Outdoor},\n" if map.Outdoor
    exporttext += "  :ShowArea => #{map.ShowArea},\n" if map.ShowArea
    exporttext += "  :Bicycle => #{map.Bicycle},\n" if map.Bicycle
    # exporttext += "  :BicycleAlways => #{map.BicycleAlways},\n" if map.BicycleAlways
    exporttext += "  :Weather => #{map.Weather},\n" if map.Weather
    exporttext += "  :DiveMap => #{map.DiveMap},\n" if map.DiveMap
    exporttext += "  :DarkMap => #{map.DarkMap},\n" if map.DarkMap
    exporttext += "  :SafariMap => #{map.SafariMap},\n" if map.SafariMap
    exporttext += "  :SnapEdges => #{map.SnapEdges},\n" if map.SnapEdges
    # exporttext += "  :Dungeon => #{map.Dungeon},\n" if map.Dungeon
    exporttext += "  :BattleBack => \"#{map.BattleBack}\",\n" if map.BattleBack
    exporttext += "  :WildBattleBGM => \"#{map.WildBattleBGM}\",\n" if map.WildBattleBGM
    exporttext += "  :TrainerBattleBGM => \"#{map.TrainerBattleBGM}\",\n" if map.TrainerBattleBGM
    exporttext += "  :WildVictoryME => \"#{map.WildVictoryME}\",\n" if map.WildVictoryME
    exporttext += "  :TrainerVictoryME => \"#{map.TrainerVictoryME}\",\n" if map.TrainerVictoryME
    exporttext += "  :MapSize => #{map.MapSize},\n" if map.MapSize
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/metatext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def metaConvert
  metadata = $cache.metadata
  exporttext = "METAHASH = {\n"
  exporttext += ":home => #{metadata[0][1].inspect},\n"
  exporttext += ":TrainerVictory => \"#{metadata[0][5]}\",\n"
  exporttext += ":WildVictory => \"#{metadata[0][4]}\",\n"
  exporttext += ":TrainerBattle => \"#{metadata[0][3]}\",\n"
  exporttext += ":WildBattle => \"#{metadata[0][2]}\",\n"
  exporttext += ":Surf => \"#{metadata[0][6]}\",\n"
  exporttext += ":Bicycle => \"#{metadata[0][7]}\",\n\n"
  for i in 8...$cache.metadata[0].length
    exporttext += ":player#{i - 7} => {\n"
    exporttext += "  :tclass => :#{getConstantName(PBTrainers, metadata[0][i][0])},\n"
    exporttext += "  #sprites,\n"
    exporttext += "  :walk => \"#{metadata[0][i][1]}\",\n" if metadata[0][i][1] != ""
    exporttext += "  :run => \"#{metadata[0][i][4]}\",\n" if metadata[0][i][4] != ""
    exporttext += "  :bike => \"#{metadata[0][i][2]}\",\n" if metadata[0][i][2] != ""
    exporttext += "  :surf => \"#{metadata[0][i][3]}\",\n" if metadata[0][i][3] != ""
    exporttext += "  :dive => \"#{metadata[0][i][5]}\",\n" if metadata[0][i][5] != ""
    exporttext += "  :fishing => \"#{metadata[0][i][6]}\",\n" if metadata[0][i][6] != ""
    exporttext += "  :surffish => \"#{metadata[0][i][7]}\",\n" if metadata[0][i][7] != ""
    exporttext += "},\n\n"
  end
  for i in 1...$cache.metadata.length
    if metadata[i].nil?
      exporttext += "\##{$cache.mapinfos[i].name}\n"
      exporttext += "#{i} => {}, \n\n"
      next
    end
    exporttext += "\##{$cache.mapinfos[i].name}\n"
    exporttext += "#{i} => { \n"
    exporttext += "  :HealingSpot => #{metadata[i][MetadataHealingSpot].inspect},\n" if metadata[i][MetadataHealingSpot]
    exporttext += "  :MapPosition => #{metadata[i][MetadataMapPosition].inspect},\n" if metadata[i][MetadataMapPosition]
    exporttext += "  :Outdoor => #{metadata[i][MetadataOutdoor]},\n" if metadata[i][MetadataOutdoor]
    exporttext += "  :ShowArea => #{metadata[i][MetadataShowArea]},\n" if metadata[i][MetadataShowArea]
    exporttext += "  :Bicycle => #{metadata[i][MetadataBicycle]},\n" if metadata[i][MetadataBicycle]
    exporttext += "  :BicycleAlways => #{metadata[i][MetadataBicycleAlways]},\n" if metadata[i][MetadataBicycleAlways]
    exporttext += "  :Weather => #{metadata[i][MetadataWeather]},\n" if metadata[i][MetadataWeather]
    exporttext += "  :DiveMap => #{metadata[i][MetadataDiveMap]},\n" if metadata[i][MetadataDiveMap]
    exporttext += "  :DarkMap => #{metadata[i][MetadataDarkMap]},\n" if metadata[i][MetadataDarkMap]
    exporttext += "  :SafariMap => #{metadata[i][MetadataSafariMap]},\n" if metadata[i][MetadataSafariMap]
    exporttext += "  :SnapEdges => #{metadata[i][MetadataSnapEdges]},\n" if metadata[i][MetadataSnapEdges]
    exporttext += "  :Dungeon => #{metadata[i][MetadataDungeon]},\n" if metadata[i][MetadataDungeon]
    exporttext += "  :BattleBack => \"#{metadata[i][MetadataBattleBack]}\",\n" if metadata[i][MetadataBattleBack]
    exporttext += "  :WildBattleBGM => \"#{metadata[i][MetadataMapWildBattleBGM]}\",\n" if metadata[i][MetadataMapWildBattleBGM]
    exporttext += "  :TrainerBattleBGM => \"#{metadata[i][MetadataMapTrainerBattleBGM]}\",\n" if metadata[i][MetadataMapTrainerBattleBGM]
    exporttext += "  :WildVictoryME => \"#{metadata[i][MetadataMapWildVictoryME]}\",\n" if metadata[i][MetadataMapWildVictoryME]
    exporttext += "  :TrainerVictoryME => \"#{metadata[i][MetadataMapTrainerVictoryME]}\",\n" if metadata[i][MetadataMapTrainerVictoryME]
    exporttext += "  :MapSize => #{metadata[i][MetadataMapSize]},\n" if metadata[i][MetadataMapSize]
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/metatext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def trainTypesDump
  exporttext = "TTYPEHASH = {\n"
  for ttype in $cache.trainertypes
    next if !ttype || ttype.empty?

    exporttext += ":#{getConstantName(PBTrainers, ttype[0])} => {\n"
    exporttext += "  :ID => #{ttype[0]},\n"
    exporttext += "  :title => \"#{ttype[2]}\",\n"
    exporttext += "  :skill => #{ttype[8]},\n"
    exporttext += "  :moneymult => #{ttype[3]},\n" if ttype[3] != 0
    exporttext += "  :battleBGM => \"#{ttype[4]}\",\n" if ttype[4]
    exporttext += "  :winBGM => \"#{ttype[5]}\",\n" if ttype[5]
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/ttypetext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def itemDump
  exclusions = (21..27).to_a + (454..464).to_a + (493..496).to_a + [50, 513]
  overworld = (1..11).to_a + [49, 690]
  evoitem = (12..20).to_a + (202..211).to_a + [692, 520, 580, 572, 193, 194, 109, 110, 105, 808, 809, 810, 811]
  utilityhold = (75..79).to_a + (120..126).to_a + [873, 70]
  battlehold = (80..94).to_a + (100..108).to_a - [105] + (111..119).to_a + [68, 71, 543, 573, 693, 648, 74, 67, 69, 849, 852]
  consumehold = (95..99).to_a + (774..777).to_a + [114, 579, 850, 66, 72, 73, 560, 576, 818, 819, 851]
  incense = (127..135).to_a
  typehold = (136..152).to_a
  plate = (153..168).to_a + [570]
  memory = (694..710).to_a
  gem = (169..185).to_a + [660]
  questitem = [40, 50, 59, 60, 61, 62, 65, 592, 594, 595, 597, 598, 604, 607, 611, 614]
  application = (669..682).to_a
  fossil = (28..36).to_a + [556, 574, 814, 815, 816, 817]
  nectar = (713..716).to_a
  justsell = (37..58).to_a - [40, 49, 50] + [63, 64, 212, 213, 214, 215, 216, 846]
  pokehold = (186..191).to_a
  legendhold = (195..201).to_a + [192, 812, 813]
  healing =  [217, 218, 219, 612, 220, 221, 234, 237, 238, 239, 711, 240, 857, 241, 242, 533, 523, 524, 605, 236, 593]
  revival = [532, 232, 233, 244, 222]
  status = [228, 243, 235, 229, 230, 231, 561, 691, 223, 224, 225, 226, 227, 527, 528, 529, 530, 531]
  pprestore = [245, 246, 247, 248]
  levelup = [526, 820, 821, 822, 823, 824, 263, 581]
  evup = (249..262).to_a + (642..647).to_a + [865, 863, 806, 848, 872, 861]
  mint = (825..845).to_a
  general = [606, 566, 516, 503, 507, 508, 509, 510, 517, 518, 504, 505, 506, 799, 866]
  important = [514, 512, 804, 807, 589, 590, 847, 869, 870, 871]
  niche = [511, 513, 608, 687, 688, 689]
  story = [525, 535, 778, 805, 534, 609, 616, 641, 800, 801, 802, 803, 856, 868]
  sidequest = [555, 596, 613, 599, 661, 683, 684, 685, 665, 666, 667, 668, 795, 796, 798]
  keys = [515, 521, 522, 536, 591, 600, 601, 602, 603, 615, 640, 686, 662, 663, 664, 794, 797, 862, 858, 859, 860]
  lakekey = [649, 650, 651, 652, 653, 654, 655, 656, 657, 658, 659]
  legendary = [854, 855, 519, 587, 588, 638, 779, 780]
  crest = (823..835).to_a + [861, 893, 894, 1039] + (864..877).to_a + (879..882).to_a + (1025..1035).to_a
  exporttext = "ITEMHASH = {\n"
  for item in $cache.items
    next if item.nil? || item.empty? || (21..27).to_a.include?(item[ITEMID]) || item[ITEMID] == 515 || item[ITEMID] == 560

    begin
      exporttext += ":#{getConstantName(PBItems, item[ITEMID])} => {\n"
    rescue
      next
    end
    exporttext += "  :ID => #{item[ITEMID]},\n"
    exporttext += "  :name => \"#{item[ITEMNAME]}\",\n"
    exporttext += "  :desc => \"#{item[ITEMDESC]}\",\n"
    exporttext += "  :price => #{item[ITEMPRICE]},\n"
    case item[ITEMPOCKET]
      when 2 then pocket = "  :medicine => true,\n"
      when 7 then exporttext += "  :battleitem => true,\n"
    end
    case item[ITEMTYPE]
      when 2 then exporttext += "  :mail => true,\n"
      when 4 then exporttext += "  :ball => true,\n"
      when 5 then exporttext += "  :berry => true,\n"
      when 6 then exporttext += "  :keyitem => true,\n"
      when 7, 8 then exporttext += "  :crystal => true,\n"
    end
    exporttext += "  :tm => :#{getConstantName(PBMoves, item[ITEMMACHINE])}\n" if item[ITEMMACHINE] != 0
    if Reborn
      exporttext += "  :overworld => true,\n" if overworld.include?(item[ITEMID])
      exporttext += "  :evoitem => true,\n" if evoitem.include?(item[ITEMID])
      exporttext += "  :utilityhold => true,\n" if utilityhold.include?(item[ITEMID])
      exporttext += "  :battlehold => true,\n" if battlehold.include?(item[ITEMID])
      exporttext += "  :consumehold => true,\n" if consumehold.include?(item[ITEMID])
      exporttext += "  :incense => true,\n" if incense.include?(item[ITEMID])
      exporttext += "  :typehold => true,\n" if typehold.include?(item[ITEMID])
      exporttext += "  :plate => true,\n" if plate.include?(item[ITEMID])
      exporttext += "  :memory => true,\n" if memory.include?(item[ITEMID])
      exporttext += "  :gem => true,\n" if gem.include?(item[ITEMID])
      exporttext += "  :questitem => true,\n" if questitem.include?(item[ITEMID])
      exporttext += "  :application => true,\n" if application.include?(item[ITEMID])
      exporttext += "  :image => \"application\",\n" if application.include?(item[ITEMID])
      exporttext += "  :fossil => true,\n" if fossil.include?(item[ITEMID])
      exporttext += "  :nectar => true,\n" if nectar.include?(item[ITEMID])
      exporttext += "  :justsell => true,\n" if justsell.include?(item[ITEMID])
      exporttext += "  :pokehold => true,\n" if pokehold.include?(item[ITEMID])
      exporttext += "  :legendhold => true,\n" if legendhold.include?(item[ITEMID])
      exporttext += "  :healing => true,\n" if healing.include?(item[ITEMID])
      exporttext += "  :revival => true,\n" if revival.include?(item[ITEMID])
      exporttext += "  :status => true,\n" if status.include?(item[ITEMID])
      exporttext += "  :pprestore => true,\n" if pprestore.include?(item[ITEMID])
      exporttext += "  :levelup => true,\n" if levelup.include?(item[ITEMID])
      exporttext += "  :evup => true,\n" if evup.include?(item[ITEMID])
      exporttext += "  :mint => true,\n" if mint.include?(item[ITEMID])
      exporttext += "  :general => true,\n" if general.include?(item[ITEMID])
      exporttext += "  :important => true,\n" if important.include?(item[ITEMID])
      exporttext += "  :niche => true,\n" if niche.include?(item[ITEMID])
      exporttext += "  :story => true,\n" if story.include?(item[ITEMID])
      exporttext += "  :sidequest => true,\n" if sidequest.include?(item[ITEMID])
      exporttext += "  :keys => true,\n" if keys.include?(item[ITEMID])
      exporttext += "  :image => \"key\",\n" if (649..659).to_a.include?(item[ITEMID])
      exporttext += "  :legendary => true,\n" if legendary.include?(item[ITEMID])
      exporttext += "  :armor => true,\n" if armor.include?(item[ITEMID])
    end
    if Rejuv
      exporttext += "  :crest => true,\n" if crest.include?(item[ITEMID])
    end
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/itemtext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def itemDumpCurrent
  exclusions, memory, mint, fossil, evup, gem, utilityhold, levelup, nectar, extramegastones, zcrystals, crest, legendhold, application, pokehold, megastones, pprestore, consumehold, keys, story, legendary, questitem, important, incense, plate, evoitem, justsell, niche, overworld, revival, status, general, battlehold, sidequest, healing, resistberries, pinchberries = Array.new(36) {
    []
  }
  if Reborn
    exclusions = (21..27).to_a + (454..464).to_a + (493..496).to_a + [50, 513]
    memory = (694..710).to_a
    mint = (825..845).to_a
    fossil = (28..36).to_a + [556, 574] + [814, 815, 816, 817]
    evup = (249..262).to_a + (642..647).to_a + [865, 863, 806, 848, 872, 861]
    levelup = [263, 526, 581, 820, 821, 822, 823, 824]
    utilityhold = (75..79).to_a + (120..126).to_a + [70, 873]
    gem = (169..185).to_a + [660]
    legendhold = (195..201).to_a + [192, 812, 813]
    application = (669..682).to_a
    pokehold = (186..191).to_a
    megastones = (537..542).to_a + (544..554).to_a + [557, 559, 562, 564, 566, 567, 568, 569, 575, 577, 578] + (617..635).to_a
    pprestore = (245..248).to_a
    consumehold = (95..99).to_a + (774..777).to_a + [114, 579, 850, 66, 72, 73, 560, 576, 818, 819, 851]
    keys = [515, 521, 522, 536, 591, 600, 601, 602, 603, 615, 640, 649, 650, 651, 652, 653, 654, 655, 656, 657, 658,
            659, 686, 662, 663, 664, 794, 797, 862, 858, 859, 860]
    story = [525, 535, 778, 805, 534, 609, 616, 641, 800, 801, 802, 803, 856, 868]
    legendary = [854, 855, 519, 587, 588, 638, 779, 780]
    questitem = [40, 50, 59, 60, 61, 62, 65, 592, 594, 595, 597, 598, 604, 607, 611, 614]
    important = [514, 512, 804, 807, 589, 590, 847, 869, 870, 871]
    incense = (127..135).to_a
    plate = (153..168).to_a + [570]
    evoitem = (12..20).to_a + (202..211).to_a + [692, 520, 580, 572, 193, 194, 109, 110, 105, 808, 809, 810, 811]
    justsell = (37..58).to_a - [40, 49, 50] + [63, 64, 212, 213, 214, 215, 216, 846]
    niche = [511, 513, 608, 687, 688, 689]
    overworld = (1..11).to_a + [49, 690]
    revival = [532, 232, 233, 244, 222]
    status = [228, 243, 235, 229, 230, 231, 561, 691, 223, 224, 225, 226, 227, 527, 528, 529, 530, 531]
    general = [606, 566, 516, 503, 507, 508, 509, 510, 517, 518, 504, 505, 506, 799, 866]
    battlehold = (80..94).to_a + (100..108).to_a - [105] + (111..119).to_a + [68, 71, 543, 573, 693, 648, 74, 67, 69, 849, 852]
    sidequest = [555, 596, 613, 599, 661, 683, 684, 685, 665, 666, 667, 668, 795, 796, 798]
    healing = [217, 218, 219, 612, 220, 221, 234, 237, 238, 239, 711, 240, 857, 241, 242, 533, 523, 524, 605, 236, 593]
    resistberries = (424..440).to_a + [571]
    pinchberries = (399..403).to_a + (441..450).to_a - [448]
  elsif Rejuv
    exclusions = (21..27).to_a + (493..496).to_a + [50, 513, 515, 560]
    memory = (694..710).to_a
    mint = (917..937).to_a
    fossil = (28..36).to_a + [556, 574] + [902, 903, 904, 905]
    evup = (249..262).to_a + (1057..1066).to_a
    utilityhold = (75..79).to_a + (120..126).to_a + [70, 1056]
    levelup = (912..916).to_a + [263, 526, 581]
    gem = (169..185).to_a + [660]
    extramegastones = (989..1019).to_a + (537..542).to_a + (544..554).to_a + [557] + [559] + [562] + (564..565).to_a + (568..569).to_a + [575] + (577..578).to_a + [616] + [661] + (781..782).to_a + (805..819).to_a + [1036]
    zcrystals = (718..772).to_a + (842..852).to_a + [1036]
    crest = (823..835).to_a + [861, 893, 894, 1039] + (864..877).to_a + (879..882).to_a + (1025..1035).to_a
    legendhold = (195..201).to_a + [192, 900, 901]
    pokehold = (186..191).to_a
    pprestore = (245..248).to_a
    consumehold = (95..99).to_a + (774..777).to_a + [114, 579, 909, 66, 72, 73, 560, 576, 906, 907, 910]
    legendary = [519, 522, 523, 1067, 840, 841]
    incense = (127..135).to_a
    plate = (153..168).to_a + [570]
    evoitem = (12..20).to_a + (202..211).to_a + [692, 535, 580, 572, 193, 194, 109, 110, 105, 896, 897, 898, 899]
    justsell = (37..58).to_a - [40, 49, 50] + [63, 64, 212, 213, 214, 215, 216]
    overworld = (1..11).to_a + [49, 690]
    revival = [649, 232, 233, 244, 222]
    status = [228, 243, 235, 229, 230, 231, 561, 691, 223, 224, 225, 226, 227]
    battlehold = (80..94).to_a + (100..108).to_a - [105] + (111..119).to_a + [68, 71, 543, 573, 693, 648, 74, 67, 69, 908, 911]
    healing =  [217, 218, 219, 680, 220, 221, 234, 237, 238, 239, 240, 241, 242, 533, 523, 524, 629, 236, 536]
    resistberries = (424..440).to_a + [571]
    pinchberries = (399..403).to_a + (441..450).to_a - [448]
  elsif Desolation
    exclusions = [49]
    memory = (655..670).to_a
    mint = (781..801).to_a
    fossil = (21..35).to_a
    evup = (251..264).to_a + (756..762).to_a
    gem = (169..186).to_a
    utilityhold = (74..78).to_a + (119..125).to_a + [69, 775]
    levelup = (776..780).to_a + [265, 532, 593]
    nectar = (673..676).to_a
    legendhold = (196..202).to_a + [193, 767, 768]
    pokehold = (186..191).to_a
    pprestore = (247..250).to_a
    consumehold = (94..98).to_a + (733..736).to_a + [113, 591, 772, 65, 71, 72, 753, 590, 769, 770, 773]
    legendary = [527, 528, 529, 755, 737, 738]
    incense = (126..134).to_a
    plate = (152..168).to_a
    evoitem = (12..20).to_a + (203..212).to_a + [653, 592, 588, 572, 194, 195, 110, 111, 106, 763, 764, 765, 767]
    justsell = (36..57).to_a - [39, 48, 49] + [62, 63, 212, 213, 214, 215, 216]
    overworld = (1..11).to_a + [49, 651]
    revival = [234, 235, 246, 224]
    status = [230, 245, 237, 231, 232, 231, 587, 652, 225, 226, 227, 228, 229]
    battlehold = (79..93).to_a + (99..107).to_a - [104] + (110..118).to_a + [67, 70, 535, 589, 654, 648, 73, 66, 68, 771, 774]
    healing =  [218, 219, 220, 612, 221, 222, 236, 239, 240, 241, 672, 242, 857, 243, 244, 238, 534]
    resistberries = (435..451).to_a + [466]
    pinchberries = (410..414).to_a + (452..460).to_a - [459]
  end
  typeboost = {
    :ELECTRIC => [:ELECTRICGEM, :MAGNET, :ZAPPLATE],
    :NORMAL => [:NORMALGEM, :SILKSCARF],
    :FIRE => [:FIREGEM, :CHARCOAL, :FLAMEPLATE],
    :WATER => [:WATERGEM, :SPLASHPLATE, :SEAINCENSE, :WAVEINCENSE, :MYSTICWATER],
    :GRASS => [:GRASSGEM, :MIRACLESEED, :MEADOWPLATE, :ROSEINCENSE],
    :FIGHTING => [:FIGHTINGGEM, :FISTPLATE, :BLACKBELT],
    :ROCK => [:ROCKGEM, :ROCKINCENSE, :STONEPLATE, :HARDSTONE],
    :PSYCHIC => [:PSYCHICGEM, :MINDPLATE, :TWISTEDSPOON, :ODDINCENSE],
    :GHOST => [:GHOSTGEM, :SPOOKYPLATE, :SPELLTAG],
    :STEEL => [:STEELGEM, :IRONPLATE, :METALCOAT],
    :FLYING => [:FLYINGGEM, :SKYPLATE, :SHARPBEAK],
    :GROUND => [:GROUNDGEM, :EARTHPLATE, :SOFTSAND],
    :DRAGON => [:DRAGONGEM, :DRACOPLATE, :DRAGONFANG],
    :POISON => [:POISONGEM, :TOXICPLATE, :POISONBARB],
    :BUG => [:BUGGEM, :INSECTPLATE, :SILVERPOWDER],
    :FAIRY => [:FAIRYGEM, :PIXIEPLATE],
    :DARK => [:DARKGEM, :DREADPLATE, :BLACKGLASSES],
    :ICE => [:ICEGEM, :ICICLEPLATE, :NEVERMELTICE],
  }
  megadescrip = "Have %s hold it, and this stone will enable it to Mega Evolve during battle."
  exporttext = "ITEMHASH = {\n"
  for i in $cache.items.keys
    item = $cache.items[i]
    next if item.nil? || exclusions.include?(item.checkFlag?(:ID))

    exporttext += ":#{i} => {\n"
    exporttext += "  :ID => #{item.checkFlag?(:ID)},\n"
    exporttext += "  :name => \"#{item.name}\",\n"
    exporttext += "  :desc => \"#{item.desc}\",\n"
    exporttext += "  :price => #{item.price},\n"
    exporttext += "  :medicine => true,\n" if item.checkFlag?(:medicine) || (healing.include?(item.checkFlag?(:ID)) || levelup.include?(item.checkFlag?(:ID)) || pprestore.include?(item.checkFlag?(:ID)) || status.include?(item.checkFlag?(:ID)) || mint.include?(item.checkFlag?(:ID)) || evup.include?(item.checkFlag?(:ID)) || revival.include?(item.checkFlag?(:ID)))
    exporttext += "  :battleitem => true,\n" if item.checkFlag?(:battleitem)
    exporttext += "  :mail => true,\n" if item.checkFlag?(:mail)
    exporttext += "  :ball => true,\n" if item.checkFlag?(:ball)
    exporttext += "  :berry => true,\n" if item.checkFlag?(:berry)
    exporttext += "  :keyitem => true,\n" if item.checkFlag?(:keyitem)
    exporttext += "  :crystal => true,\n" if item.checkFlag?(:crystal) || megastones.include?(item.checkFlag?(:ID))
    exporttext += "  :zcrystal => true,\n" if item.checkFlag?(:zcrystal)
    exporttext += "  :tm => :#{item.checkFlag?(:tm)},\n" if item.checkFlag?(:tm) != false
    exporttext += "  :overworld => true,\n" if item.checkFlag?(:overworld) || overworld.include?(item.checkFlag?(:ID))
    exporttext += "  :evoitem => true,\n" if item.checkFlag?(:evoitem) || evoitem.include?(item.checkFlag?(:ID))
    exporttext += "  :crest => true,\n" if item.checkFlag?(:crest)
    exporttext += "  :noUseInBattle => true,\n" if !(ItemHandlers.hasBattleUseOnBattler(i) || ItemHandlers.hasBattleUseOnPokemon(i) || ItemHandlers.hasBattleUseOnPokemon(i))
    exporttext += "  :noUse => true,\n" if !(ItemHandlers.hasOutHandler(i) || (pbIsTM?(i)))
    exporttext += "  :utilityhold => true,\n" if item.checkFlag?(:utilityhold)
    exporttext += "  :battlehold => true,\n" if item.checkFlag?(:battlehold) || battlehold.include?(item.checkFlag?(:ID))
    exporttext += "  :consumehold => true,\n" if item.checkFlag?(:consumehold) || consumehold.include?(item.checkFlag?(:ID))
    exporttext += "  :resistberry => true,\n" if item.checkFlag?(:resistberry) || resistberries.include?(item.checkFlag?(:ID))
    exporttext += "  :pinchberry => true,\n" if item.checkFlag?(:pinchberry) || pinchberries.include?(item.checkFlag?(:ID))
    exporttext += "  :incense => true,\n" if item.checkFlag?(:incense) || incense.include?(item.checkFlag?(:ID))
    if item.checkFlag?(:typeboost)
      exporttext += "  :typeboost => \:#{item.checkFlag?(:typeboost)}\,\n"
    else
      typeboost.each_pair { |typeboost, typeboostitems|
        exporttext += "  :typeboost => \:#{typeboost}\,\n" if typeboostitems.include?(i)
      }
    end
    exporttext += "  :plate => true,\n" if item.checkFlag?(:plate) || plate.include?(item.checkFlag?(:ID))
    exporttext += "  :memory => true,\n" if item.checkFlag?(:memory) || memory.include?(item.checkFlag?(:ID))
    exporttext += "  :gem => true,\n" if item.checkFlag?(:gem) || gem.include?(item.checkFlag?(:ID))
    exporttext += "  :questitem => true,\n" if item.checkFlag?(:questitem) || questitem.include?(item.checkFlag?(:ID))
    exporttext += "  :application => true,\n" if item.checkFlag?(:application) || application.include?(item.checkFlag?(:ID))
    exporttext += "  :image => \"application\",\n" if item.checkFlag?(:application) || application.include?(item.checkFlag?(:ID))
    exporttext += "  :fossil => true,\n" if item.checkFlag?(:fossil) || fossil.include?(item.checkFlag?(:ID))
    exporttext += "  :nectar => true,\n" if item.checkFlag?(:nectar) || nectar.include?(item.checkFlag?(:ID))
    exporttext += "  :justsell => true,\n" if item.checkFlag?(:justsell) || justsell.include?(item.checkFlag?(:ID))
    exporttext += "  :pokehold => true,\n" if item.checkFlag?(:pokehold) || pokehold.include?(item.checkFlag?(:ID))
    exporttext += "  :legendhold => true,\n" if item.checkFlag?(:legendhold) || legendhold.include?(item.checkFlag?(:ID))
    exporttext += "  :healing => true,\n" if item.checkFlag?(:healing) || healing.include?(item.checkFlag?(:ID))
    exporttext += "  :revival => true,\n" if item.checkFlag?(:revival) || revival.include?(item.checkFlag?(:ID))
    exporttext += "  :status => true,\n" if item.checkFlag?(:status) || status.include?(item.checkFlag?(:ID))
    exporttext += "  :pprestore => true,\n" if item.checkFlag?(:pprestore) || pprestore.include?(item.checkFlag?(:ID))
    exporttext += "  :levelup => true,\n" if item.checkFlag?(:levelup) || levelup.include?(item.checkFlag?(:ID))
    exporttext += "  :evup => true,\n" if item.checkFlag?(:evup) || evup.include?(item.checkFlag?(:ID))
    exporttext += "  :mint => true,\n" if item.checkFlag?(:mint) || mint.include?(item.checkFlag?(:ID))
    exporttext += "  :general => true,\n" if item.checkFlag?(:general) || general.include?(item.checkFlag?(:ID))
    exporttext += "  :important => true,\n" if item.checkFlag?(:important) || important.include?(item.checkFlag?(:ID))
    exporttext += "  :niche => true,\n" if item.checkFlag?(:niche) || niche.include?(item.checkFlag?(:ID))
    exporttext += "  :story => true,\n" if item.checkFlag?(:story) || story.include?(item.checkFlag?(:ID))
    exporttext += "  :sidequest => true,\n" if item.checkFlag?(:sidequest) || sidequest.include?(item.checkFlag?(:ID))
    exporttext += "  :keys => true,\n" if item.checkFlag?(:keys) || keys.include?(item.checkFlag?(:ID))
    exporttext += "  :image => \"keys\",\n" if item.checkFlag?(:keys) || keys.include?(item.checkFlag?(:ID))
    exporttext += "  :legendary => true,\n" if item.checkFlag?(:legendary) || legendary.include?(item.checkFlag?(:ID))
    exporttext += "},\n\n"
  end
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/itemtext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def monDump(mons = $cache.pkmn, game: GAMEFOLDER)
  exporttext = "MONHASH = {\n"
  cprint "Beginning #{"Pokemon".yellow} dump...\n"
  mons.each { |mon, wrapper|
    cprint "Pokemon #{mon.to_s.yellow}"
    exporttext += wrapper.export
    cprint "             \r"
  }
  exporttext += "}\n"
  cprint "Success.                                                \n".green
  File.open("Scripts/" + game + "/montext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def moveDump
  # updated to work with the new cache set up
  exporttext = "MOVEHASH = {\n"
  for i in $cache.moves.keys
    # next if i == 569
    move = $cache.moves[i]
    exporttext += ":#{i} => {\n"
    exporttext += "  :ID => #{move.checkFlag?(:ID)},\n"
    exporttext += "  :name => \"#{move.name}\",\n"
    exporttext += sprintf("  :function => 0x%03X,\n", move.function)
    exporttext += "  :type => :#{move.type},\n"
    exporttext += "  :category => :#{move.category},\n"
    exporttext += "  :basedamage => #{move.basedamage},\n"
    exporttext += "  :accuracy => #{move.accuracy},\n"
    exporttext += "  :maxpp => #{move.maxpp},\n"
    exporttext += "  :effect => #{move.checkFlag?(:effect)},\n" if move.checkFlag?(:effect) != false
    exporttext += "  :effect => #{move.checkFlag?(:moreeffect)},\n" if move.checkFlag?(:moreeffect) != false
    exporttext += "  :target => :#{move.target},\n"
    exporttext += "  :priority => #{move.priority},\n" if move.priority && move.priority != 0
    exporttext += "  :contact => true,\n" if move.checkFlag?(:contact)
    exporttext += "  :bypassprotect => true,\n" if move.checkFlag?(:bypassprotect)
    exporttext += "  :magiccoat => true,\n" if move.checkFlag?(:magiccoat)
    exporttext += "  :snatchable => true,\n" if move.checkFlag?(:snatchable)
    exporttext += "  :nonmirror => true,\n" if move.checkFlag?(:nonmirror)
    exporttext += "  :defrost => true,\n" if move.checkFlag?(:defrost)
    exporttext += "  :highcrit => true,\n" if move.checkFlag?(:highcrit)
    exporttext += "  :healingmove => true,\n" if move.checkFlag?(:healingmove)
    exporttext += "  :punchmove => true,\n" if move.checkFlag?(:punchmove)
    exporttext += "  :soundmove => true,\n" if move.checkFlag?(:soundmove)
    exporttext += "  :gravityblocked => true,\n" if move.checkFlag?(:gravityblocked)
    exporttext += "  :beammove => true,\n" if move.checkFlag?(:beammove)
    exporttext += "  :recoil => #{move.checkFlag?(:recoil)},\n"
    exporttext += "  :desc => \"#{move.desc}\"\n"
    exporttext += "},\n\n"
    System.set_window_title("Move line #{i}")
  end
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/movetext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def encDump
  enctypeChances = [
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [50, 25, 15, 7, 3],
    [50, 25, 15, 7, 3],
    [70, 30],
    [60, 20, 20],
    [40, 35, 15, 7, 3],
    [30, 25, 20, 10, 5, 5, 4, 1],
    [30, 25, 20, 10, 5, 5, 4, 1],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2],
    [20, 15, 12, 10, 10, 10, 5, 5, 5, 4, 2, 2]
  ]
  exporttext = "ENCHASH = {\n"
  $cache.encounters.each { |id, map|
    exporttext += "#{id} => { \##{$cache.mapinfos[id].name}\n"
    exporttext += "  :landrate => #{map[0][0]},\n" if map[0][0] != 0
    exporttext += "  :caverate => #{map[0][1]},\n" if map[0][1] != 0
    exporttext += "  :waterrate => #{map[0][2]},\n" if map[0][2] != 0
    encounterdata = map[1]
    for enc in 0...encounterdata.length
      sectiontext = ""
      next if !encounterdata[enc]

      case enc
        when 0 then exporttext += "  :Land => [\n"
        when 1 then exporttext += "  :Cave => [\n"
        when 2 then exporttext += "  :Water => [\n"
        when 3 then exporttext += "  :RockSmash => [\n"
        when 4 then exporttext += "  :OldRod => [\n"
        when 5 then exporttext += "  :GoodRod => [\n"
        when 6 then exporttext += "  :SuperRod => [\n"
        when 7 then exporttext += "  :Headbutt => [\n"
        when 9 then sectiontext = "  :LandMorning => [\n"
        when 10 then sectiontext = "  :LandDay => [\n"
        when 11 then sectiontext = "  :LandNight => [\n"
        when 8 then next
      end
      if [9, 10, 11].include?(enc) # skip this section if it's no different than the standard land encounters
        next if encounterdata[0] == encounterdata[enc]

        exporttext += sectiontext
      end
      # now get the mons with their weight, species, and level range
      for index in 0...encounterdata[enc].length
        monname = getConstantName(PBSpecies, encounterdata[enc][index][0])
        exporttext += "    [:#{monname},#{enctypeChances[enc][index]},#{encounterdata[enc][index][1]},#{encounterdata[enc][index][2]}]"
        if index != encounterdata[enc].length - 1
          exporttext += ","
        end
        exporttext += "\n"
      end
      exporttext += "  ],\n"
    end
    exporttext += "},\n"
  }
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/enctext.rb", "w") { |f|
    f.write(exporttext)
  }
  fixEncountersSeveralSameMon
end

def fixEncountersSeveralSameMon
  if File.exists?("Scripts/" + GAMEFOLDER + "/enctext.rb")
    file = File.open("Scripts/" + GAMEFOLDER + "/enctext.rb", "r+")
    file_data = file.read
    currentarray = []
    blackjack = "" # and hookers
    file_data.each_line { |line|
      if line.include?("},") && currentarray.length > 0
        line2 = ""
        currentarray.each { |x|
          x = x.insert(x.index('['), '[')
          if x[-2] == ','
            x = x[0...-3] + ']]' + x[-2] + x[-1]
          else
            x = x[0...-2] + ']],' + x[-1]
          end
          line2 += x
        }
        currentarray = []
        line2 += line
        blackjack += line2
      elsif line.include?(" => [")
        index = currentarray.index { |s| s.include?(line.split(" => ")[0]) }
        if !index.nil?
          currentarray[index] = currentarray[index][0...-1] + line.split(" => ")[1]
        else
          currentarray.push(line)
        end
      else
        blackjack += line
      end
    }
    file.truncate(0)
    file.rewind
    file.write(blackjack)
    file.close
  else
    puts "uuuh why is there no enctext.rb file found"
  end
end

def getConstantName(mod, value)
  for c in mod.constants
    return c if mod.const_get(c.to_sym) == value
  end
  raise _INTL("Value {1} not defined by a constant in {2}", value, mod.name)
end

def dumpTeams
  exporttext = "TEAMARRAY = [\n"
  for trainer in $cache.trainers
    next if trainer.empty?

    exporttext += "{\n"
    exporttext += ":teamid => [\"#{trainer[1]}\",:#{getConstantName(PBTrainers, trainer[0])},#{trainer[4]}],\n"
    if !trainer[2].empty?
      exporttext += ":items => ["
      check = 1
      for item in trainer[2]
        exporttext += ":#{getConstantName(PBItems, item)}"
        exporttext += "," if check != trainer[2].length
        check += 1
      end
      exporttext += "],\n"
    end
    exporttext += ":mons => [\n"
    check = 1
    for mon in trainer[3]
      exporttext += "{\n"
      exporttext += "  :species => :#{getConstantName(PBSpecies, mon[0])},\n"
      exporttext += "  :level => #{mon[1]},\n"
      exporttext += "  :item => :#{getConstantName(PBItems, mon[2])},\n" if mon[2] != 0
      if mon[3] != 0
        exporttext += "  :moves => [:#{getConstantName(PBMoves, mon[3])},"
        exporttext += ":#{getConstantName(PBMoves, mon[4])}" if mon[4] != 0
        exporttext += ","
        exporttext += ":#{getConstantName(PBMoves, mon[5])}" if mon[5] != 0
        exporttext += ","
        exporttext += ":#{getConstantName(PBMoves, mon[6])}" if mon[6] != 0
        exporttext += "],\n"
      end
      abilities = [
        $cache.pkmn[mon[0]][:Abilities][0],
        $cache.pkmn[mon[0]][:Abilities][1],
        $cache.pkmn[mon[0]][:HiddenAbilities],
      ]
      formnames = $PokemonForms.dig(mon[0], :FormName)
      name = formnames[mon[9]] if formnames
      name = "Female" if mon[0] == :MEOWSTIC && mon[8] == 1
      v = $PokemonForms.dig(mon[0], name, :Abilities)
      abilities = v if v
      abilities = [abilities, abilities, abilities] if !abilities.is_a?(Array)
      abilities[2] = abilities[0] if abilities[2] == 0 || abilities[2].nil?
      abilities[1] = abilities[2] if abilities[1] == 0 || abilities[1].nil?
      ability = mon[7] ? mon[7] : 0
      begin
        exporttext += "  :ability => :#{getConstantName(PBAbilities, abilities[ability])},\n"
      rescue
        puts trainer, ttype, partyid, getConstantName(PBSpecies, mon[0]), abilities.inspect
      end
      if mon[8]
        case mon[8]
          when 0 then exporttext += "  :gender => \"M\",\n"
          when 1 then exporttext += "  :gender => \"F\",\n"
          when 2 then exporttext += "  :gender => \"N\",\n"
        end
      end
      exporttext += "  :form => #{mon[9]},\n" if mon[9] != 0
      exporttext += "  :shiny => true,\n" if mon[10]
      exporttext += "  :nature => :#{getConstantName(PBNatures, mon[11])},\n" if mon[11] != PBNatures::HARDY
      exporttext += "  :iv => #{mon[12]},\n" if mon[12] != 10
      exporttext += "  :happiness => #{mon[13]},\n" if mon[13] != 70
      exporttext += "  :name => \"#{mon[14]}\",\n" if mon[14]
      exporttext += "  :shadow => true,\n" if mon[15]
      evtotal = mon[18] + mon[19] + mon[20] + mon[21] + mon[22] + mon[23]
      if evtotal > 0 && evtotal != ([(mon[1] * 1.5).floor, 85].max * 6)
        exporttext += "  :ev => [#{mon[18]},#{mon[19]},#{mon[23]},#{mon[21]},#{mon[22]},#{mon[20]}]"
      end
      if check != trainer[3].length
        exporttext += "},\n"
      else
        exporttext += "}"
      end
      check += 1
    end
    exporttext += "]},\n"
  end
  exporttext += "]\n"
  File.open("Scripts/" + GAMEFOLDER + "/trainertext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def convertTeam
  lines = []
  linenos = []
  lineno = 1
  File.open("PBS/trainers.txt", "rb") { |f|
    FileLineData.file = "PBS/trainers.txt"
    f.each_line { |line|
      line = prepline(line)
      if line != ""
        lines.push(line)
        linenos.push(lineno)
      end
      lineno += 1
    }
  }
  nameoffset = 0
  trainers = []
  trainernames = []
  i = 0; loop do
    break unless i < lines.length

    FileLineData.setLine(lines[i], linenos[i])
    trainername = lines[i]
    FileLineData.setLine(lines[i + 1], linenos[i + 1])
    nameline = strsplit(lines[i + 1], /\s*,\s*/)
    name = nameline[0]
    raise _INTL("Trainer name too long\r\n{1}", FileLineData.linereport) if name.length >= 0x10000

    trainernames.push(name)
    partyid = 0
    if nameline[1] && nameline[1] != ""
      raise _INTL("Expected a number for the trainer battle ID\r\n{1}", FileLineData.linereport) if !nameline[1][/^\d+$/]

      partyid = nameline[1].to_i
    end
    FileLineData.setLine(lines[i + 2], linenos[i + 2])
    items = strsplit(lines[i + 2], /\s*,\s*/)
    items[0].gsub!(/^\s+/, "")
    raise _INTL("Expected a number for the number of Pokémon\r\n{1}", FileLineData.linereport) if !items[0][/^\d+$/]

    numpoke = items[0].to_i
    realitems = []
    for j in 1...items.length # Number of Pokémon and items held by Trainer
      realitems.push(items[j].to_sym)
    end
    pkmn = []
    for j in 0...numpoke
      FileLineData.setLine(lines[i + j + 3], linenos[i + j + 3])
      poke = strsplit(lines[i + j + 3], /\s*,\s*/)
      mon = {}
      poke[0] = poke[0].to_sym
      mon.store(:species, poke[0])
      mon.store(:level, poke[1].to_i) # Level

      if !poke[2] || poke[2] == "" # item
        # next
      else
        mon.store(:item, poke[2].to_sym)
      end

      strmoves = [poke[3], poke[4], poke[5], poke[6]]
      moves = []
      strmoves.each { |mv|
        if mv && mv != ""
          moves.push(mv.to_sym)
        end
      }
      mon.store(:moves, moves) if !moves.empty?

      if !poke[7] || poke[7] == "" # Ability
        # next
      else
        abillist = $cache.pkmn[poke[0]].Abilities
        abillist += [$cache.pkmn[poke[0]].flags[:HiddenAbilities]] if $cache.pkmn[poke[0]].checkFlag?(:HiddenAbilities)
        mon.store(:ability, abillist[poke[7].to_i])
      end
      if !poke[8] || poke[8] == "" # Gender
        # poke[8]=nil
      else
        mon.store(:gender, ["M", "F"][poke[8].to_i])
      end
      if !poke[9] || poke[9] == "" # Form
        # poke[9]=0
      else
        mon.store(:form, poke[9].to_i)
      end
      if !poke[10] || poke[10] == ""
      else
        mon.store(:shiny, true) if csvBoolean!(poke[10].clone) == true # Shiny
      end
      if !poke[11] || poke[11] == ""
      else
        mon.store(:nature, poke[11].to_sym)
      end
      mon.store(:iv, 31) # IVS
      if !poke[13] || poke[13] == "" # Happiness
        # poke[13]=70
      else
        mon.store(:happiness, poke[13].to_i)
      end
      if !poke[14] || poke[14] == "" # Nickname
        # poke[14]=nil
      else
        mon.store(:name, poke[14].to_s)
        #       raise _INTL("Bad nickname: {1} (must be 1-10 characters)\r\n{2}",poke[14],FileLineData.linereport) if (poke[14].to_s).length>10
      end
      mon.store(:ev, [[85, mon[:level] * 3 / 2].min] * 6)
      poke.flatten! # catch any nils
      pkmn.push(mon)
    end
    i += 3 + numpoke
    trainers.push([trainername, name, realitems, pkmn, partyid])
    nameoffset += name.length
  end

  exporttext = "TEAMARRAY = ["
  for trainer in trainers
    next if trainer.empty?

    exporttext += "{\n"
    exporttext += ":teamid => [\"#{trainer[1]}\",:#{trainer[0]},#{trainer[4]}],\n"
    if !trainer[2].empty?
      exporttext += ":items => ["
      check = 1
      for item in trainer[2]
        exporttext += ":#{item}"
        exporttext += "," if check != trainer[2].length
        check += 1
      end
      exporttext += "],\n"
    end
    exporttext += ":mons => ["
    check = 1
    for mon in trainer[3]
      exporttext += "{\n"
      exporttext += "\t:species => :#{mon[:species]},\n"
      exporttext += "\t:name => \"#{mon[:name]}\",\n" if mon[:name]
      exporttext += "\t:level => #{mon[:level]},\n"
      exporttext += "\t:item => :#{mon[:item]},\n" if mon[:item]
      exporttext += "\t:moves => #{mon[:moves].inspect},\n" if mon[:moves]
      exporttext += "\t:ability => :#{mon[:ability]},\n" if mon[:ability]
      exporttext += "\t:gender => #{mon[:gender].inspect},\n" if mon[:gender]
      exporttext += "\t:form => #{mon[:form]},\n" if mon[:form]
      exporttext += "\t:shiny => true,\n" if mon[:shiny]
      exporttext += "\t:nature => :#{mon[:nature]},\n" if mon[:nature]
      exporttext += "\t:iv => #{mon[:iv]},\n" if mon[:iv]
      exporttext += "\t:ev => #{mon[:ev].inspect},\n" if mon[:ev]
      exporttext += "\t:happiness => #{mon[:happiness]},\n" if mon[:happiness]
      if check != trainer[3].length
        exporttext += "},\n"
      else
        exporttext += "}"
      end
      check += 1
    end
    exporttext += "]},\n"
  end
  exporttext += "]"
  File.open("Scripts/" + GAMEFOLDER + "/trainertext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def connectionsConvert
  exporttext = "MAPCONNECTIONSHASH = {\n"
  mapdata = load_data("Data/connections.dat")
  mapdata.each { |connection|
    case connection[1]
      when "N"
        connection[1] = "North"
      when "E"
        connection[1] = "East"
      when "S"
        connection[1] = "South"
      when "W"
        connection[1] = "West"
    end
    case connection[4]
      when "N"
        connection[4] = "North"
      when "E"
        connection[4] = "East"
      when "S"
        connection[4] = "South"
      when "W"
        connection[4] = "West"
    end
    exporttext += "#{connection[0]} => { \##{$cache.mapinfos[connection[0]].name}\n"
    exporttext += "  :connections => [#{connection}"
    $cache.map_conns.each { |connection2|
      case connection2[1]
        when "N"
          connection2[1] = "North"
        when "E"
          connection2[1] = "East"
        when "S"
          connection2[1] = "South"
        when "W"
          connection2[1] = "West"
      end
      case connection2[4]
        when "N"
          connection2[4] = "North"
        when "E"
          connection2[4] = "East"
        when "S"
          connection2[4] = "South"
        when "W"
          connection2[4] = "West"
      end
      exporttext += ",  #{connection2}" if (connection2[0] == connection[0]) && (connection[3] != connection2[3])
    }
    exporttext += "],\n"
    exporttext += "},\n"
  }
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/mapconnections.rb", "w") { |f|
    f.write(exporttext)
  }
end

def connectionsDump
  exporttext = "MAPCONNECTIONSHASH = {\n"
  mapdata = load_data("Data/connections.dat")
  mapdata.each_pair { |key, value|
    exporttext += "#{key} => {  \##{$cache.mapinfos[key].name}\n "
    exporttext += "  :connections => [\n  "
    for i in 0...value[:connections].length
      conn = value[:connections][i]
      exporttext += "#{conn}"
      if conn != value[:connections][-1]
        exporttext += ", \# to #{$cache.mapinfos[conn[3]].name}\n  "
      else
        exporttext += " \# to #{$cache.mapinfos[conn[3]].name}\n"
      end
    end
    exporttext += "  ],\n"
    exporttext += "},\n"
  }
  exporttext += "}\n"
  File.open("Scripts/" + GAMEFOLDER + "/mapconnections.rb", "w") { |f|
    f.write(exporttext)
  }
end

def bttDump
  File.open("Scripts/" + GAMEFOLDER + "/PBSpecies.rb") { |f|
    eval(f.read)
  }
  File.open("Scripts/" + GAMEFOLDER + "/PBTrainers.rb") { |f|
    eval(f.read)
  }
  exporttext = "BTTARRAY = [\n"
  for trainer in load_data("Data/trainerlists.dat")[0][0]
    exporttext += "{\n"
    exporttext += "  :type => :#{getConstantName(PBTrainers, trainer[0])},\n"
    exporttext += "  :name => \"#{trainer[1]}\",\n"
    exporttext += "  :quote => \"#{trainer[2]}\",\n"
    exporttext += "  :win => \"#{trainer[3]}\",\n"
    exporttext += "  :loss => \"#{trainer[4]}\",\n"
    exporttext += "  :mons => [\n"
    check = 1
    for mon in trainer[5]
      exporttext += ":#{getConstantName(PBSpecies, mon)}"
      exporttext += "," if check != trainer[5].length
      check += 1
    end
    exporttext += "],\n"
    exporttext += "},\n"
  end
  exporttext += "]\n"
  File.open("Scripts/" + GAMEFOLDER + "/btttext.rb", "w") { |f|
    f.write(exporttext)
  }
end

def dumpDefeatAceLines
  globaltext = ""
  for n in 1..999
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name, "rb") { true } rescue false)
    next if $cache.mapinfos[n].name == "REMOVED"

    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0
        while index < list.length - 1
          params = list[index].parameters
          for l in 0..params.length
            text = params[l].to_s
            if (text.include? "pbTrainerBattle") || (text.include? "pbDoubleTrainerBattle")
              globaltext << text + "\n"
            end
          end
          index += 1
        end
      end
    end
  end
  file = File.open("output.txt", "w+")
  file.puts(globaltext)
  file.rewind
  file_data = file.read
  lossLines = {}
  file_data.each_line { |line|
    if line.strip.start_with?("pbTrainerBattle") && !line.include?("pbGet(602)")
      line = line.split(":")[1]
      numbattle = 0
      if !line.split(")")[1][/\d+/].nil?
        numbattle = line.split(")")[1][/\d+/]
      end
      line = line.split(")")[0]
      line = line.gsub! "_I(", (numbattle.to_s + ",")
      string = line.split(",")[1] + ",:" + line.split(",")[0] + "," + line.split(",")[2]
      lossLines[string] = line.partition(/(?:[^,]*,){3}/).last.delete("\n")
    elsif line.start_with?("pbDoubleTrainerBattle") && !line.include?("pbGet(602)")
      line1 = line.split("(:")[1].split("),")[0]
      line2 = line.split(",:")[1].split(")")[0]
      line1.gsub!("_I(", "")
      line2.gsub!("_I(", "")
      string = line1.split(",")[1] + ",:" + line1.split(",")[0] + "," + line1.split(",")[2]
      lossLines[string] = line1.partition(/(?:[^,]*,){3}/).last.delete("\n")
      string = line2.split(",")[1] + ",:" + line2.split(",")[0] + "," + line2.split(",")[2]
      lossLines[string] = line2.partition(/(?:[^,]*,){3}/).last.delete("\n")
    end
  }
  file.close

  aceLines = {}
  if File.exists?("Scripts/" + GAMEFOLDER + "/toconvert.txt")
    file = File.open("Scripts/" + GAMEFOLDER + "/toconvert.txt", "r")
    file_data = file.read
    key = ""
    text = ""
    num = 0
    file_data.each_line { |line|
      if line.strip.start_with?("when :")
        key = ""
        text = ""
        key = line.split("when ")[1].strip
      elsif line.strip.start_with?("when")
        key = key + "," + line.strip.split(" then ace_text")[0].split("when ")[1]
        text = line.strip.split("= _INTL(")[1][0...-1]
        aceLines[key] = text
      elsif line.strip.include?("if isConst?(trainertext")
        key = ""
        num = ""
        text = ""
        key = line.split("PBTrainers,")[1].strip.delete("\n")[0...-1]
      elsif line.strip.start_with?("if $game_variables[192]") || line.strip.start_with?("if $game_variables[226]")
        num = line.split("==")[1].strip.delete("\n")
      elsif line.strip.start_with?("pbDisplayPaused")
        key = key + "," + num
        text = line.strip.split("_INTL(")[1][0...-2]
        aceLines[key] = text
      end
    }
    file.close
  end

  if File.exists?("Scripts/" + GAMEFOLDER + "/trainertext.rb")
    file = File.open("Scripts/" + GAMEFOLDER + "/trainertext.rb", "r+")
    file_data = file.read
    file2 = File.open("Scripts/" + GAMEFOLDER + "/trainertext - Backup.rb", "w")
    file2.write(file_data)
    file2.close
    file_data.each_line { |line|
      if line.include?(":teamid =>")
        id = line.split(":teamid => [")[1][0...-3]
        if lossLines.key?(id)
          string = "  :defeat => " + lossLines[id].to_s
          file_data[line] = line + string + ",\n"
        end
        idace = id.partition(/(?:[^,]*,){1}/).last
        if aceLines.key?(idace)
          string = "  :ace => " + aceLines[idace].to_s
          file_data[line] = line + string + ",\n"
        end
      end
    }
    file.truncate(0)
    file.rewind
    file.write(file_data)
    file.close
  else
    puts "uuuh why is there no trainertext.rb file found"
  end
  File.delete("output.txt") if File.exist?("output.txt")
end

def evLineFixer
  if File.exists?("Scripts/" + GAMEFOLDER + "/trainertext.rb")
    file = File.open("Scripts/" + GAMEFOLDER + "/trainertext.rb", "r")
    file_data = file.read
    file_data.each_line { |line|
      if line.strip.start_with?(":ev =>")
        key = line.split(":ev =>")[1].strip
        front = key.split("}")[0]
        back = line.split(/\d+[\]]/)[1].strip
        evarray = eval(front)
        speed = evarray.delete_at(3)
        evarray.push(speed)
        evline = ""
        evline += "  :ev => #{evarray}#{back}\n"
        file_data[line] = evline
      end
    }
    File.open("Scripts/" + GAMEFOLDER + "/trainertext.rb", "w") { |f|
      f.write(file_data)
    }
    file.close
  else
    puts "uuuh why is there no trainertext.rb file found"
  end
end

# Mass Fixes event constants
def removeDefeatText
  for n in 0...999
    savemap = false
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name, "rb") { true } rescue false)

    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0
        while index < list.length - 1
          case list[index].code # checks for event codes. here those are scripts(355), additional lines of scripts(655) and conditional branches(111)
            when 355, 655
              text = list[index].parameters[0]
              if text.include?("pbTrainerBattle")
                savemap = true
                map.events[i].pages[j].list[index].parameters[0].gsub!(/_I\((.*)\),/, "")
              elsif text.include?("pbDoubleTrainerBattle")
                front = text.split(/\),:/)[0].strip + ")"
                back = ":" + text.split(/\),:/)[1].strip
                newfront = front.gsub!(/_I\((.*)\)/, "")
                newback = back.gsub!(/_I\((.*)\),/, "")
                newtext = newfront + newback
                savemap = true
                map.events[i].pages[j].list[index].parameters[0] = newtext
              end
            when 111
              if list[index].parameters[0] == 12 # if conditional branch holds scripts in it
                text = list[index].parameters[1] # for conditional branches, the script text is stored in index 1 as opposed to index 0
                if text.include?("pbTrainerBattle")
                  savemap = true
                  map.events[i].pages[j].list[index].parameters[1].gsub!(/_I\((.*)\),/, "")
                elsif text.include?("pbDoubleTrainerBattle")
                  front = text.split(/\),:/)[0].strip + ")"
                  back = ":" + text.split(/\),:/)[1].strip
                  newfront = front.gsub!(/_I\((.*)\)/, "")
                  newback = back.gsub!(/_I\((.*)\),/, "")
                  newtext = newfront + newback
                  savemap = true
                  map.events[i].pages[j].list[index].parameters[1] = newtext
                end
              end
          end
          index += 1
        end
      end
    end
    if savemap
      save_data(map, sprintf("Data/Map%03d.rxdata", n))
    end
  end
end

# Mass Fixes event constants
def pbEventConstantFixer
  for n in 0...999
    savemap = false
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name, "rb") { true } rescue false)

    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0
        trainerlinestring = "_I(".*")"
        constantlinks = ["PBTrainers::", "PBSpecies::", "PBItems::", "PBMoves::"] # list of constants that need to be changed
        while index < list.length - 1
          case list[index].code # checks for event codes. here those are scripts(355), additional lines of scripts(655) and conditional branches(111)
            when 355, 655
              text = list[index].parameters[0]
              constantlinks.each do |constant|
                if text.include?(constant)
                  savemap = true
                  map.events[i].pages[j].list[index].parameters[0].gsub! constant, ':'
                end
              end
            when 111
              if list[index].parameters[0] == 12 # if conditional branch holds scripts in it
                text = list[index].parameters[1] # for conditional branches, the script text is stored in index 1 as opposed to index 0
                constantlinks.each do |constant|
                  if text.include?(constant)
                    savemap = true
                    map.events[i].pages[j].list[index].parameters[1].gsub! constant, ':'
                  end
                end
              end
          end
          index += 1
        end
      end
    end
    if savemap
      save_data(map, sprintf("Data/Map%03d.rxdata", n))
    end
  end
end

def fieldrewrite # rewrite the rewrite at some point
  output = "FIELDEFFECTS = {\n"
  FIELDEFFECTS.each { |key, data|
    name = data[:FIELDGRAPHICS]
    output += ":#{name.strip.upcase.gsub(/\d/, '')} => {\n"

    output += "  :name => \"#{data.dig(:FIELDNAME)}\",\n"
    messagetext = ""
    if data.dig(:INTROMESSAGE).is_a?(Array)
      messagetext = "[\n"
      data.dig(:INTROMESSAGE).each { |msg|
        messagetext += "    \"#{msg}\",\n"
      }
      messagetext += "  ]"
    else
      messagetext = "[\n    \"#{data.dig(:INTROMESSAGE)}\"\n  ]"
    end
    output += "  :fieldMessage => #{messagetext},\n"
    output += "  :graphic => \"#{data.dig(:FIELDGRAPHICS)}\",\n"
    output += "  :secretPower => \"#{data.dig(:SECRETPOWERANIM)}\",\n"
    output += "  :naturePower => \"#{data.dig(:NATUREMOVES)}\",\n"
    output += "  :mimicry => \"#{data.dig(:MIMICRY)}\",\n"

    output += "  :damageMods => "
    if data.dig(:MOVEDAMAGEBOOST)
      output += "{\n"
      data.dig(:MOVEDAMAGEBOOST).each { |mult, moves|
        output += "    #{mult} => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :accuracyMods => "
    if data.dig(:MOVEACCURACYBOOST)
      output += "{\n"
      data.dig(:MOVEACCURACYBOOST).each { |acc, moves|
        output += "    #{acc} => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :moveMessages => "
    if data.dig(:MOVEMESSAGES)
      output += "{\n"
      data.dig(:MOVEMESSAGES).each { |msg, moves|
        output += "    \"#{msg}\" => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeMods => "
    if data.dig(:MOVETYPEMOD)
      output += "{\n"
      data.dig(:MOVETYPEMOD).each { |type, moves|
        output += "    :#{type} => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeAddOns => "
    if data.dig(:TYPETYPEMOD)
      output += "{\n"
      data.dig(:TYPETYPEMOD).each { |type, type2|
        output += "    :#{type} => #{type2},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeBoosts => "
    if data.dig(:TYPEDAMAGEBOOST)
      output += "{\n"
      data.dig(:TYPEDAMAGEBOOST).each { |boost, types|
        output += "    #{boost} => #{types},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeMessages => "
    if data.dig(:TYPEMESSAGES)
      output += "{\n"
      data.dig(:TYPEMESSAGES).each { |msg, type|
        output += "    \"#{msg}\" => #{type},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :typeCondition => "
    if data.dig(:TYPECONDITION)
      output += "{\n"
      data.dig(:TYPECONDITION).each { |type, condition|
        output += "    :#{type} => \"#{condition}\",\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :changeCondition => "
    if data.dig(:CHANGECONDITION)
      output += "{\n"
      data.dig(:CHANGECONDITION).each { |fieldid, condition|
        fieldsym = FIELDEFFECTS[fieldid][:FIELDGRAPHICS].strip.upcase
        output += "    :#{fieldsym} => \"#{condition}\",\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :fieldChange => "
    if data.dig(:FIELDCHANGE)
      output += "{\n"
      data.dig(:FIELDCHANGE).each { |fieldid, condition|
        fieldsym = FIELDEFFECTS[fieldid][:FIELDGRAPHICS].strip.upcase
        output += "    :#{fieldsym} => #{condition},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :dontChangeBackup => #{data.dig(:DONTCHANGEBACKUP) ? data.dig(:DONTCHANGEBACKUP) : "[]"},\n"

    output += "  :changeMessage => "
    if data.dig(:CHANGEMESSAGE)
      output += "{\n"
      data.dig(:CHANGEMESSAGE).each { |msg, moves|
        output += "     \"#{msg}\" => #{moves},\n"
      }
      output += "  },\n"
    else
      output += "{},\n"
    end

    output += "  :statusMods => #{data.dig(:STATUSMOVEBOOST) ? data.dig(:STATUSMOVEBOOST) : "[]"},\n"
    output += "  :changeEffects => {},\n"
    output += "  :seed => {\n"

    seedtext = ""
    if data.dig(:SEED).is_a?(Hash) || data.dig(:SEED).nil?
      seedtext = "nil"
    else
      seedtext = ":#{data.dig(:SEED)}"
    end

    output += "    :seedtype => #{seedtext},\n"

    effecttext = ""
    if data.dig(:SEEDEFFECT)
      if data.dig(:SEEDEFFECT).is_a?(Symbol)
        effecttext = ":"
      end
      effecttext += data.dig(:SEEDEFFECT).to_s
    else
      effecttext = "nil"
    end
    output += "    :effect => #{effecttext},\n"

    durtext = ""
    if data.dig(:SEEDEFFECTVAL)
      if data.dig(:SEEDEFFECTVAL).is_a?(Symbol)
        durtext = ":"
      end
      durtext += data.dig(:SEEDEFFECTVAL).to_s
    else
      durtext = "nil"
    end
    output += "    :duration => #{durtext},\n"

    output += "    :message => #{data.dig(:SEEDEFFECTSTR) ? "\"" + data.dig(:SEEDEFFECTSTR).to_s + "\"" : "nil"},\n"

    anitext = ""
    if data.dig(:SEEDANIM)
      if data.dig(:SEEDANIM).is_a?(Symbol)
        anitext = ":"
      end
      anitext += data.dig(:SEEDANIM).to_s
    else
      anitext = "nil"
    end
    output += "    :animation => #{anitext},\n"

    output += "    :stats => "

    if data.dig(:SEEDSTATS)
      output += "{\n"
      hash = {
        :HP => 0,
        :ATTACK => 1,
        :DEFENSE => 2,
        :SPATK => 3,
        :SPDEF => 4,
        :SPEED => 5,
        :ACCURACY => 6,
        :EVASION => 7
      }
      data.dig(:SEEDSTATS).each { |stat, val|
        output += "      PBStats::#{hash.keys[stat]} => #{val},\n"
      }
      output += "    },\n"
    else
      output += "{}\n"
    end

    output += "  },\n},\n"
  }
  output += "}"

  File.open("Scripts/" + GAMEFOLDER + "/fieldtext.rb", "w") { |f|
    f.write(output)
  }
  compileFields
end

def dumpNatures
  dumpstupidstats = [
    ["PBStats::ATTACK", "\"spicy\""],
    ["PBStats::DEFENSE", "\"sour\""],
    ["PBStats::SPEED", "\"sweet\""],
    ["PBStats::SPATK", "\"dry\""],
    ["PBStats::SPDEF", "\"bitter\""]
  ]
  output = "NATUREHASH = {\n"
  for nature in 0..PBNatures.maxValue
    incStat = (nature / 5).floor
    decStat = (nature % 5).floor
    output += ":#{PBNatures.getName(nature).upcase} => {\n"
    output += "    :name => \"#{PBNatures.getName(nature)}\",\n"
    output += "    :incStat => #{dumpstupidstats[incStat][0]},\n"
    output += "    :decStat => #{dumpstupidstats[decStat][0]},\n"
    output += "    :like => #{dumpstupidstats[incStat][1]},\n"
    output += "    :dislike => #{dumpstupidstats[decStat][1]},\n"
    output += "  },\n"
  end
  output += "}"


  File.open("Scripts/" + GAMEFOLDER + "/naturetext.rb", "w") { |f|
    f.write(output)
  }
end

def convertBTMons
  # Only works if all sets of the same mon are contiguous in the PBS. -Orsan
  File.open("Scripts/ConversionClasses.rb") { |f| eval(f.read) }
  output = "BTMONS = {\n"
  lastmon = nil
  pbCompilerEachCommentedLine("PBS/btpokemon.txt") { |line, lineno|
    currentmon = PBPokemon.fromInspected(line)
    if lineno <= 1
      output += currentmon.speciesinspect + " => [\n"
    elsif currentmon.species != lastmon.species
      output += "],\n" + currentmon.speciesinspect + " => [\n"
    end
    output += "  " + currentmon.to_s_no_species
    lastmon = currentmon
  }
  output += "]\n}"
  File.open("Scripts/" + GAMEFOLDER + "/btpokemon.rb", "w") { |f|
    f.write(output)
  }
end

def dumpBTMons
  output = "BTMONS = [\n"
  pbCompilerEachCommentedLine("PBS/btpokemon.txt") { |line, lineno|
    output += BTPokemon.fromInspected(line).to_s
  }
  output += "]"
  File.open("Scripts/" + GAMEFOLDER + "/btpokemon.rb", "w") { |f|
    f.write(output)
  }
end

def convertBTTrainers
  output = "BTTRAINERS = [\n"
  btTrainersRequiredTypes = {
    "Type" => [0, "s"],
    "Name" => [1, "s"],
    "BeginSpeech" => [2, "s"],
    "EndSpeechWin" => [3, "s"],
    "EndSpeechLose" => [4, "s"],
    "PokemonNos" => [5, "*u"]
  }
  requiredtypes = btTrainersRequiredTypes
  if safeExists?("PBS/bttrainers.txt")
    File.open("PBS/bttrainers.txt", "rb") { |f|
      FileLineData.file = "PBS/bttrainers.txt"
      pbEachFileSectionEx(f) { |section, name|
        rsection = []
        for key in section.keys
          FileLineData.setSection(name, key, section[key])
          schema = requiredtypes[key]
          next if !schema

          record = pbGetCsvRecord(section[key], 0, schema)
          rsection[schema[0]] = record
        end
        output += "{\n"
        output += "  :tclass => :#{rsection[0]},\n"
        output += "  :name => #{rsection[1].inspect},\n"
        output += "  :introSpeech => #{rsection[2].inspect},\n"
        output += "  :winSpeech => #{rsection[3].inspect},\n"
        output += "  :loseSpeech => #{rsection[4].inspect},\n"
        mons = rsection[5].inspect[1..-2].split(",")
        output += "  :monIndexes => ["
        for mon in mons
          if mon.to_i != 0
            output += ":"
            output += $cache.pkmn.keys[mon.to_i - 1].to_s
            if mon != mons[mons.size - 1]
              output += ","
            end
          end
        end
        output += "],\n"
        output += "},\n"
      }
    }
  end
  output += "]"
  File.open("Scripts/" + GAMEFOLDER + "/bttrainers.rb", "w") { |f|
    f.write(output)
  }
end
