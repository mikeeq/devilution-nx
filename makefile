ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>/devkitpro")
endif

TOPDIR ?= $(CURDIR)

export BUILD_EXEFS_SRC := build/exefs

include $(DEVKITPRO)/libnx/switch_rules

APP_TITLE 	:= diablo-nx
APP_AUTHOR 	:= MVG
APP_VERSION := 1.0.0
APP_ICON 		:= icon.jpg
BUILD				:= build
DATA				:= data
INCLUDES		:= include
EXEFS_SRC		:= exefs_src
ROMFS				:= RomFS

BINDIR	= release
OUTPUT  = diablo

# ifeq ($(strip $(ICON)),)
# 	icons := $(wildcard *.jpg)
# 	ifneq (,$(findstring $(TARGET).jpg,$(icons)))
# 		export APP_ICON := $(TOPDIR)/$(TARGET).jpg
# 	else
# 		ifneq (,$(findstring icon.jpg,$(icons)))
# 			export APP_ICON := $(TOPDIR)/icon.jpg
# 		endif
# 	endif
# else
# 	export APP_ICON := $(TOPDIR)/$(ICON)
# endif

ifeq ($(strip $(NO_ICON)),)
	export NROFLAGS += --icon=$(APP_ICON)
endif

ifneq ($(APP_TITLEID),)
	export NACPFLAGS += --titleid=$(APP_TITLEID)
endif

ifneq ($(ROMFS),)
	export NROFLAGS += --romfsdir=$(CURDIR)/$(OUTPUTDIR)/$(ROMFS)
endif

ifeq ($(TARGET),)
TARGET = diablo
endif

# compiler, linker and utilities
AR 				= aarch64-none-elf-gcc-ar
CC 				= aarch64-none-elf-gcc
CPP 			= aarch64-none-elf-g++
LINK 			= aarch64-none-elf-g++
ASM 			= @nasm
ASMFLAGS 	= -f coff
MD 				= mkdir
RM 				= @rm -rf

SMACKEROBJ 		= $(OBJDIR)/smk_bitstream.o $(OBJDIR)/smk_hufftree.o $(OBJDIR)/smacker.o
RADONOBJ			= $(OBJDIR)/File.o $(OBJDIR)/Key.o $(OBJDIR)/Named.o $(OBJDIR)/Section.o
STORMLIBOBJ		= $(OBJDIR)/FileStream.o $(OBJDIR)/SBaseCommon.o $(OBJDIR)/SBaseFileTable.o $(OBJDIR)/SBaseSubTypes.o $(OBJDIR)/SCompression.o $(OBJDIR)/SFileExtractFile.o $(OBJDIR)/SFileFindFile.o $(OBJDIR)/SFileGetFileInfo.o $(OBJDIR)/SFileOpenArchive.o $(OBJDIR)/SFileOpenFileEx.o $(OBJDIR)/SFileReadFile.o
PKWAREOBJ			= $(OBJDIR)/explode.o $(OBJDIR)/implode.o
DEVILUTIONOBJ = $(OBJDIR)/appfat.o $(OBJDIR)/automap.o $(OBJDIR)/capture.o $(OBJDIR)/codec.o $(OBJDIR)/control.o $(OBJDIR)/cursor.o $(OBJDIR)/dead.o $(OBJDIR)/debug.o $(OBJDIR)/diablo.o $(OBJDIR)/doom.o $(OBJDIR)/drlg_l1.o $(OBJDIR)/drlg_l2.o $(OBJDIR)/drlg_l3.o $(OBJDIR)/drlg_l4.o $(OBJDIR)/dthread.o $(OBJDIR)/effects.o $(OBJDIR)/encrypt.o $(OBJDIR)/engine.o $(OBJDIR)/error.o $(OBJDIR)/fault.o $(OBJDIR)/gamemenu.o $(OBJDIR)/gendung.o $(OBJDIR)/gmenu.o $(OBJDIR)/help.o $(OBJDIR)/init.o $(OBJDIR)/interfac.o $(OBJDIR)/inv.o $(OBJDIR)/itemdat.o $(OBJDIR)/items.o $(OBJDIR)/lighting.o $(OBJDIR)/loadsave.o $(OBJDIR)/logging.o $(OBJDIR)/mmainmenu.o $(OBJDIR)/minitext.o $(OBJDIR)/misdat.o $(OBJDIR)/missiles.o $(OBJDIR)/monstdat.o $(OBJDIR)/monster.o $(OBJDIR)/movie.o $(OBJDIR)/mpqapi.o $(OBJDIR)/msgcmd.o $(OBJDIR)/msg.o $(OBJDIR)/multi.o $(OBJDIR)/nthread.o $(OBJDIR)/objdat.o $(OBJDIR)/objects.o $(OBJDIR)/pack.o $(OBJDIR)/palette.o $(OBJDIR)/path.o $(OBJDIR)/pfile.o $(OBJDIR)/player.o $(OBJDIR)/plrctrls.o $(OBJDIR)/plrmsg.o $(OBJDIR)/portal.o $(OBJDIR)/spelldat.o $(OBJDIR)/quests.o $(OBJDIR)/render.o $(OBJDIR)/restrict.o $(OBJDIR)/scrollrt.o $(OBJDIR)/setmaps.o $(OBJDIR)/sha.o $(OBJDIR)/spells.o $(OBJDIR)/stores.o $(OBJDIR)/sync.o $(OBJDIR)/textdat.o $(OBJDIR)/themes.o $(OBJDIR)/tmsg.o $(OBJDIR)/town.o $(OBJDIR)/towners.o $(OBJDIR)/track.o $(OBJDIR)/trigs.o $(OBJDIR)/wave.o
MAINOBJ				= $(OBJDIR)/dx.o $(OBJDIR)/misc.o $(OBJDIR)/misc_io.o $(OBJDIR)/misc_msg.o $(OBJDIR)/misc_dx.o $(OBJDIR)/rand.o $(OBJDIR)/thread.o $(OBJDIR)/dsound.o $(OBJDIR)/ddraw.o $(OBJDIR)/sound.o $(OBJDIR)/storm.o $(OBJDIR)/storm_net.o $(OBJDIR)/storm_dx.o $(OBJDIR)/abstract_net.o $(OBJDIR)/loopback.o $(OBJDIR)/packet.o $(OBJDIR)/base.o $(OBJDIR)/frame_queue.o $(OBJDIR)/tcp_client.o $(OBJDIR)/tcp_server.o $(OBJDIR)/udp_p2p.o $(OBJDIR)/credits.o $(OBJDIR)/diabloui.o $(OBJDIR)/dialogs.o $(OBJDIR)/mainmenu.o $(OBJDIR)/progress.o $(OBJDIR)/selconn.o $(OBJDIR)/selgame.o $(OBJDIR)/selhero.o $(OBJDIR)/title.o $(OBJDIR)/main.o

LIBS      = -specs=$(DEVKITPRO)/libnx/switch.specs -g -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE -L$(DEVKITPRO)/libnx/lib -L$(DEVKITPRO)/portlibs/switch/lib -lSDL2_mixer -lSDL2_ttf -lfreetype -lvorbisfile -lvorbis -logg -lmodplug -lmikmod -lmpg123 -lSDL2 -lEGL -lglapi -ldrm_nouveau -lpng -lbz2 -lz -lnx
INCS      = -I$(DEVKITPRO)/portlibs/switch/include/SDL2 -I"Source" -I"SourceS" -I"SourceX" -I"3rdParty/asio/include" -I"3rdParty/Radon/Radon/include" -I"3rdParty/libsmacker" -I$(DEVKITPRO)/libnx/include -I$(DEVKITPRO)/portlibs/switch/include -Iswitch
CXXINCS   = -I$(DEVKITPRO)/portlibs/switch/include/SDL2 -I"Source" -I"SourceS" -I"SourceX" -I"3rdParty/asio/include" -I"3rdParty/Radon/Radon/include" -I"3rdParty/libsmacker" -I$(DEVKITPRO)/libnx/include -I$(DEVKITPRO)/portlibs/switch/include -Iswitch
BIN       = $(BINDIR)/diablo-nx.elf
BUILD	  	= build
OUTPUTDIR = output
BINDIR	  = $(OUTPUTDIR)/release
OBJDIR		= $(OUTPUTDIR)/obj
DEFINES   = -DSWITCH -DPLATFORM_NX -DSDL2 -DDEVILUTION_STUB -DDEVILUTION_ENGINE -DASIO_STANDALONE -DASIO_HEADER_ONLY
CXXFLAGS  = $(CXXINCS) $(DEFINES) -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE -fsigned-char -Wall -Wextra -Wno-write-strings -fpermissive -Wno-write-strings -Wno-multichar -w -O2
CFLAGS    = $(INCS) $(DEFINES)    -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE -fsigned-char -Wall -Wextra -Wno-write-strings -fpermissive -Wno-write-strings -Wno-multichar -w -O2
GPROF     = gprof.exe
RM        = rm -rf
OUTPUT    = diablo-nx

.PHONY: dirs all all-before all-after clean clean-custom

all: dirs all-before $(BIN) all-after

dirs:
	$(MD) -p $(OUTPUTDIR) $(OBJDIR) $(BINDIR) $(OUTPUTDIR)/$(ROMFS)

clean: clean-custom
	$(RM) $(OUTPUTDIR)

$(BIN): $(MAINOBJ) $(SMACKEROBJ) $(RADONOBJ) $(STORMLIBOBJ) $(PKWAREOBJ) $(DEVILUTIONOBJ)
	$(LINK) $(MAINOBJ) $(SMACKEROBJ) $(RADONOBJ) $(STORMLIBOBJ) $(PKWAREOBJ) $(DEVILUTIONOBJ) -o "$(BIN)" $(LIBS)

#Smacker

$(OBJDIR)/smk_bitstream.o: $(GLOBALDEPS) 3rdParty/libsmacker/smk_bitstream.c
	$(CC) -c 3rdParty/libsmacker/smk_bitstream.c -o $(OBJDIR)/smk_bitstream.o $(CFLAGS)
$(OBJDIR)/smk_hufftree.o: $(GLOBALDEPS) 3rdParty/libsmacker/smk_hufftree.c
	$(CC) -c 3rdParty/libsmacker/smk_hufftree.c -o $(OBJDIR)/smk_hufftree.o $(CFLAGS)
$(OBJDIR)/smacker.o: $(GLOBALDEPS) 3rdParty/libsmacker/smacker.c
	$(CC) -c 3rdParty/libsmacker/smacker.c -o $(OBJDIR)/smacker.o $(CFLAGS)

#Radon

$(OBJDIR)/File.o: $(GLOBALDEPS) 3rdParty/Radon/Radon/source/File.cpp
	$(CPP) -c 3rdParty/Radon/Radon/source/File.cpp -o $(OBJDIR)/File.o $(CXXFLAGS)
$(OBJDIR)/Key.o: $(GLOBALDEPS) 3rdParty/Radon/Radon/source/Key.cpp
	$(CPP) -c 3rdParty/Radon/Radon/source/Key.cpp -o $(OBJDIR)/Key.o $(CXXFLAGS)
$(OBJDIR)/Named.o: $(GLOBALDEPS) 3rdParty/Radon/Radon/source/Named.cpp
	$(CPP) -c 3rdParty/Radon/Radon/source/Named.cpp -o $(OBJDIR)/Named.o $(CXXFLAGS)
$(OBJDIR)/Section.o: $(GLOBALDEPS) 3rdParty/Radon/Radon/source/Section.cpp
	$(CPP) -c 3rdParty/Radon/Radon/source/Section.cpp -o $(OBJDIR)/Section.o $(CXXFLAGS)

#StormLib

$(OBJDIR)/FileStream.o: $(GLOBALDEPS) 3rdParty/StormLib/src/FileStream.cpp
	$(CPP) -c 3rdParty/StormLib/src/FileStream.cpp -o $(OBJDIR)/FileStream.o $(CXXFLAGS)
$(OBJDIR)/SBaseCommon.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SBaseCommon.cpp
	$(CPP) -c 3rdParty/StormLib/src/SBaseCommon.cpp -o $(OBJDIR)/SBaseCommon.o $(CXXFLAGS)
$(OBJDIR)/SBaseFileTable.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SBaseFileTable.cpp
	$(CPP) -c 3rdParty/StormLib/src/SBaseFileTable.cpp -o $(OBJDIR)/SBaseFileTable.o $(CXXFLAGS)
$(OBJDIR)/SBaseSubTypes.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SBaseSubTypes.cpp
	$(CPP) -c 3rdParty/StormLib/src/SBaseSubTypes.cpp -o $(OBJDIR)/SBaseSubTypes.o $(CXXFLAGS)
$(OBJDIR)/SCompression.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SCompression.cpp
	$(CPP) -c 3rdParty/StormLib/src/SCompression.cpp -o $(OBJDIR)/SCompression.o $(CXXFLAGS)
$(OBJDIR)/SFileExtractFile.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SFileExtractFile.cpp
	$(CPP) -c 3rdParty/StormLib/src/SFileExtractFile.cpp -o $(OBJDIR)/SFileExtractFile.o $(CXXFLAGS)
$(OBJDIR)/SFileFindFile.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SFileFindFile.cpp
	$(CPP) -c 3rdParty/StormLib/src/SFileFindFile.cpp -o $(OBJDIR)/SFileFindFile.o $(CXXFLAGS)
$(OBJDIR)/SFileGetFileInfo.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SFileGetFileInfo.cpp
	$(CPP) -c 3rdParty/StormLib/src/SFileGetFileInfo.cpp -o $(OBJDIR)/SFileGetFileInfo.o $(CXXFLAGS)
$(OBJDIR)/SFileOpenArchive.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SFileOpenArchive.cpp
	$(CPP) -c 3rdParty/StormLib/src/SFileOpenArchive.cpp -o $(OBJDIR)/SFileOpenArchive.o $(CXXFLAGS)
$(OBJDIR)/SFileOpenFileEx.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SFileOpenFileEx.cpp
	$(CPP) -c 3rdParty/StormLib/src/SFileOpenFileEx.cpp -o $(OBJDIR)/SFileOpenFileEx.o $(CXXFLAGS)
$(OBJDIR)/SFileReadFile.o: $(GLOBALDEPS) 3rdParty/StormLib/src/SFileReadFile.cpp
	$(CPP) -c 3rdParty/StormLib/src/SFileReadFile.cpp -o $(OBJDIR)/SFileReadFile.o $(CXXFLAGS)

#PKWare

$(OBJDIR)/explode.o: $(GLOBALDEPS) 3rdParty/PKWare/explode.cpp
	$(CPP) -c 3rdParty/PKWare/explode.cpp -o $(OBJDIR)/explode.o $(CXXFLAGS)
$(OBJDIR)/implode.o: $(GLOBALDEPS) 3rdParty/PKWare/implode.cpp
	$(CPP) -c 3rdParty/PKWare/implode.cpp -o $(OBJDIR)/implode.o $(CXXFLAGS)

#Devilution
$(OBJDIR)/appfat.o: $(GLOBALDEPS) Source/appfat.cpp
	$(CPP) -c Source/appfat.cpp -o $(OBJDIR)/appfat.o $(CXXFLAGS)
$(OBJDIR)/automap.o: $(GLOBALDEPS) Source/automap.cpp
	$(CPP) -c Source/automap.cpp -o $(OBJDIR)/automap.o $(CXXFLAGS)
$(OBJDIR)/capture.o: $(GLOBALDEPS)  Source/capture.cpp
	$(CPP) -c  Source/capture.cpp -o $(OBJDIR)/capture.o $(CXXFLAGS)
$(OBJDIR)/codec.o: $(GLOBALDEPS) Source/codec.cpp
	$(CPP) -c Source/codec.cpp -o $(OBJDIR)/codec.o $(CXXFLAGS)
$(OBJDIR)/control.o: $(GLOBALDEPS) Source/control.cpp
	$(CPP) -c Source/control.cpp -o $(OBJDIR)/control.o $(CXXFLAGS)
$(OBJDIR)/cursor.o: $(GLOBALDEPS) Source/cursor.cpp
	$(CPP) -c Source/cursor.cpp -o $(OBJDIR)/cursor.o $(CXXFLAGS)
$(OBJDIR)/dead.o: $(GLOBALDEPS) Source/dead.cpp
	$(CPP) -c Source/dead.cpp -o $(OBJDIR)/dead.o $(CXXFLAGS)
$(OBJDIR)/debug.o: $(GLOBALDEPS) Source/debug.cpp
	$(CPP) -c Source/debug.cpp -o $(OBJDIR)/debug.o $(CXXFLAGS)
$(OBJDIR)/diablo.o: $(GLOBALDEPS) Source/diablo.cpp
	$(CPP) -c Source/diablo.cpp -o $(OBJDIR)/diablo.o $(CXXFLAGS)
$(OBJDIR)/doom.o: $(GLOBALDEPS) Source/doom.cpp
	$(CPP) -c Source/doom.cpp -o $(OBJDIR)/doom.o $(CXXFLAGS)
$(OBJDIR)/drlg_l1.o: $(GLOBALDEPS)  Source/drlg_l1.cpp
	$(CPP) -c  Source/drlg_l1.cpp -o $(OBJDIR)/drlg_l1.o $(CXXFLAGS)
$(OBJDIR)/drlg_l2.o: $(GLOBALDEPS) Source/drlg_l2.cpp
	$(CPP) -c Source/drlg_l2.cpp -o $(OBJDIR)/drlg_l2.o $(CXXFLAGS)
$(OBJDIR)/drlg_l3.o: $(GLOBALDEPS) Source/drlg_l3.cpp
	$(CPP) -c Source/drlg_l3.cpp -o $(OBJDIR)/drlg_l3.o $(CXXFLAGS)
$(OBJDIR)/drlg_l4.o: $(GLOBALDEPS) Source/drlg_l4.cpp
	$(CPP) -c Source/drlg_l4.cpp -o $(OBJDIR)/drlg_l4.o $(CXXFLAGS)
$(OBJDIR)/dthread.o: $(GLOBALDEPS) Source/dthread.cpp
	$(CPP) -c Source/dthread.cpp -o $(OBJDIR)/dthread.o $(CXXFLAGS)
$(OBJDIR)/effects.o: $(GLOBALDEPS) Source/effects.cpp
	$(CPP) -c Source/effects.cpp -o $(OBJDIR)/effects.o $(CXXFLAGS)
$(OBJDIR)/encrypt.o: $(GLOBALDEPS)  Source/encrypt.cpp
	$(CPP) -c  Source/encrypt.cpp -o $(OBJDIR)/encrypt.o $(CXXFLAGS)
$(OBJDIR)/engine.o: $(GLOBALDEPS) Source/engine.cpp
	$(CPP) -c Source/engine.cpp -o $(OBJDIR)/engine.o $(CXXFLAGS)
$(OBJDIR)/error.o: $(GLOBALDEPS) Source/error.cpp
	$(CPP) -c Source/error.cpp -o $(OBJDIR)/error.o $(CXXFLAGS)
$(OBJDIR)/fault.o: $(GLOBALDEPS) Source/fault.cpp
	$(CPP) -c Source/fault.cpp -o $(OBJDIR)/fault.o $(CXXFLAGS)
$(OBJDIR)/gamemenu.o: $(GLOBALDEPS)  Source/gamemenu.cpp
	$(CPP) -c  Source/gamemenu.cpp -o $(OBJDIR)/gamemenu.o $(CXXFLAGS)
$(OBJDIR)/gendung.o: $(GLOBALDEPS)  Source/gendung.cpp
	$(CPP) -c  Source/gendung.cpp -o $(OBJDIR)/gendung.o $(CXXFLAGS)
$(OBJDIR)/gmenu.o: $(GLOBALDEPS)  Source/gmenu.cpp
	$(CPP) -c  Source/gmenu.cpp -o $(OBJDIR)/gmenu.o $(CXXFLAGS)
$(OBJDIR)/help.o: $(GLOBALDEPS)  Source/help.cpp
	$(CPP) -c  Source/help.cpp -o $(OBJDIR)/help.o $(CXXFLAGS)
$(OBJDIR)/init.o: $(GLOBALDEPS)  Source/init.cpp
	$(CPP) -c  Source/init.cpp -o $(OBJDIR)/init.o $(CXXFLAGS)
$(OBJDIR)/interfac.o: $(GLOBALDEPS)  Source/interfac.cpp
	$(CPP) -c  Source/interfac.cpp -o $(OBJDIR)/interfac.o $(CXXFLAGS)
$(OBJDIR)/inv.o: $(GLOBALDEPS)  Source/inv.cpp
	$(CPP) -c  Source/inv.cpp -o $(OBJDIR)/inv.o $(CXXFLAGS)
$(OBJDIR)/itemdat.o: $(GLOBALDEPS)  Source/itemdat.cpp
	$(CPP) -c  Source/itemdat.cpp -o $(OBJDIR)/itemdat.o $(CXXFLAGS)
$(OBJDIR)/items.o: $(GLOBALDEPS)  Source/items.cpp
	$(CPP) -c  Source/items.cpp -o $(OBJDIR)/items.o $(CXXFLAGS)
$(OBJDIR)/lighting.o: $(GLOBALDEPS)  Source/lighting.cpp
	$(CPP) -c  Source/lighting.cpp -o $(OBJDIR)/lighting.o $(CXXFLAGS)
$(OBJDIR)/loadsave.o: $(GLOBALDEPS)  Source/loadsave.cpp
	$(CPP) -c  Source/loadsave.cpp -o $(OBJDIR)/loadsave.o $(CXXFLAGS)
$(OBJDIR)/logging.o: $(GLOBALDEPS)  Source/logging.cpp
	$(CPP) -c  Source/logging.cpp -o $(OBJDIR)/logging.o $(CXXFLAGS)
$(OBJDIR)/mmainmenu.o: $(GLOBALDEPS)  Source/mainmenu.cpp
	$(CPP) -c  Source/mainmenu.cpp -o $(OBJDIR)/mmainmenu.o $(CXXFLAGS)
$(OBJDIR)/minitext.o: $(GLOBALDEPS)  Source/minitext.cpp
	$(CPP) -c  Source/minitext.cpp -o $(OBJDIR)/minitext.o $(CXXFLAGS)
$(OBJDIR)/misdat.o: $(GLOBALDEPS)  Source/misdat.cpp
	$(CPP) -c  Source/misdat.cpp -o $(OBJDIR)/misdat.o $(CXXFLAGS)
$(OBJDIR)/missiles.o: $(GLOBALDEPS)  Source/missiles.cpp
	$(CPP) -c  Source/missiles.cpp -o $(OBJDIR)/missiles.o $(CXXFLAGS)
$(OBJDIR)/monstdat.o: $(GLOBALDEPS)  Source/monstdat.cpp
	$(CPP) -c  Source/monstdat.cpp -o $(OBJDIR)/monstdat.o $(CXXFLAGS)
$(OBJDIR)/monster.o: $(GLOBALDEPS)  Source/monster.cpp
	$(CPP) -c  Source/monster.cpp -o $(OBJDIR)/monster.o $(CXXFLAGS)
$(OBJDIR)/movie.o: $(GLOBALDEPS)  Source/movie.cpp
	$(CPP) -c  Source/movie.cpp -o $(OBJDIR)/movie.o $(CXXFLAGS)
$(OBJDIR)/mpqapi.o: $(GLOBALDEPS)  Source/mpqapi.cpp
	$(CPP) -c  Source/mpqapi.cpp -o $(OBJDIR)/mpqapi.o $(CXXFLAGS)
$(OBJDIR)/msgcmd.o: $(GLOBALDEPS)  Source/msgcmd.cpp
	$(CPP) -c  Source/msgcmd.cpp -o $(OBJDIR)/msgcmd.o $(CXXFLAGS)
$(OBJDIR)/msg.o: $(GLOBALDEPS)  Source/msg.cpp
	$(CPP) -c  Source/msg.cpp -o $(OBJDIR)/msg.o $(CXXFLAGS)
$(OBJDIR)/multi.o: $(GLOBALDEPS)  Source/multi.cpp
	$(CPP) -c  Source/multi.cpp -o $(OBJDIR)/multi.o $(CXXFLAGS)
$(OBJDIR)/nthread.o: $(GLOBALDEPS)  Source/nthread.cpp
	$(CPP) -c  Source/nthread.cpp -o $(OBJDIR)/nthread.o $(CXXFLAGS)
$(OBJDIR)/objdat.o: $(GLOBALDEPS)  Source/objdat.cpp
	$(CPP) -c  Source/objdat.cpp -o $(OBJDIR)/objdat.o $(CXXFLAGS)
$(OBJDIR)/objects.o: $(GLOBALDEPS)  Source/objects.cpp
	$(CPP) -c  Source/objects.cpp -o $(OBJDIR)/objects.o $(CXXFLAGS)
$(OBJDIR)/pack.o: $(GLOBALDEPS)  Source/pack.cpp
	$(CPP) -c  Source/pack.cpp -o $(OBJDIR)/pack.o $(CXXFLAGS)
$(OBJDIR)/palette.o: $(GLOBALDEPS)  Source/palette.cpp
	$(CPP) -c  Source/palette.cpp -o $(OBJDIR)/palette.o $(CXXFLAGS)
$(OBJDIR)/path.o: $(GLOBALDEPS)  Source/path.cpp
	$(CPP) -c  Source/path.cpp -o $(OBJDIR)/path.o $(CXXFLAGS)
$(OBJDIR)/pfile.o: $(GLOBALDEPS)  Source/pfile.cpp
	$(CPP) -c  Source/pfile.cpp -o $(OBJDIR)/pfile.o $(CXXFLAGS)
$(OBJDIR)/player.o: $(GLOBALDEPS)  Source/player.cpp
	$(CPP) -c  Source/player.cpp -o $(OBJDIR)/player.o $(CXXFLAGS)
$(OBJDIR)/plrmsg.o: $(GLOBALDEPS)  Source/plrmsg.cpp
	$(CPP) -c  Source/plrmsg.cpp -o $(OBJDIR)/plrmsg.o $(CXXFLAGS)
$(OBJDIR)/plrctrls.o: $(GLOBALDEPS) Source/plrctrls.cpp
	$(CPP) -c Source/plrctrls.cpp -o $(OBJDIR)/plrctrls.o $(CXXFLAGS)
$(OBJDIR)/portal.o: $(GLOBALDEPS)  Source/portal.cpp
	$(CPP) -c  Source/portal.cpp -o $(OBJDIR)/portal.o $(CXXFLAGS)
$(OBJDIR)/spelldat.o: $(GLOBALDEPS)  Source/spelldat.cpp
	$(CPP) -c  Source/spelldat.cpp -o $(OBJDIR)/spelldat.o $(CXXFLAGS)
$(OBJDIR)/quests.o: $(GLOBALDEPS)  Source/quests.cpp
	$(CPP) -c  Source/quests.cpp -o $(OBJDIR)/quests.o $(CXXFLAGS)
$(OBJDIR)/render.o: $(GLOBALDEPS)  Source/render.cpp
	$(CPP) -c  Source/render.cpp -o $(OBJDIR)/render.o $(CXXFLAGS)
$(OBJDIR)/restrict.o: $(GLOBALDEPS)  Source/restrict.cpp
	$(CPP) -c  Source/restrict.cpp -o $(OBJDIR)/restrict.o $(CXXFLAGS)
$(OBJDIR)/scrollrt.o: $(GLOBALDEPS)  Source/scrollrt.cpp
	$(CPP) -c  Source/scrollrt.cpp -o $(OBJDIR)/scrollrt.o $(CXXFLAGS)
$(OBJDIR)/setmaps.o: $(GLOBALDEPS)  Source/setmaps.cpp
	$(CPP) -c  Source/setmaps.cpp -o $(OBJDIR)/setmaps.o $(CXXFLAGS)
$(OBJDIR)/sha.o: $(GLOBALDEPS)  Source/sha.cpp
	$(CPP) -c  Source/sha.cpp -o $(OBJDIR)/sha.o $(CXXFLAGS)
$(OBJDIR)/spells.o: $(GLOBALDEPS)  Source/spells.cpp
	$(CPP) -c  Source/spells.cpp -o $(OBJDIR)/spells.o $(CXXFLAGS)
$(OBJDIR)/stores.o: $(GLOBALDEPS)  Source/stores.cpp
	$(CPP) -c  Source/stores.cpp -o $(OBJDIR)/stores.o $(CXXFLAGS)
$(OBJDIR)/sync.o: $(GLOBALDEPS)  Source/sync.cpp
	$(CPP) -c  Source/sync.cpp -o $(OBJDIR)/sync.o $(CXXFLAGS)
$(OBJDIR)/textdat.o: $(GLOBALDEPS)  Source/textdat.cpp
	$(CPP) -c  Source/textdat.cpp -o $(OBJDIR)/textdat.o $(CXXFLAGS)
$(OBJDIR)/themes.o: $(GLOBALDEPS)  Source/themes.cpp
	$(CPP) -c  Source/themes.cpp -o $(OBJDIR)/themes.o $(CXXFLAGS)
$(OBJDIR)/tmsg.o: $(GLOBALDEPS)  Source/tmsg.cpp
	$(CPP) -c  Source/tmsg.cpp -o $(OBJDIR)/tmsg.o $(CXXFLAGS)
$(OBJDIR)/town.o: $(GLOBALDEPS)  Source/town.cpp
	$(CPP) -c  Source/town.cpp -o $(OBJDIR)/town.o $(CXXFLAGS)
$(OBJDIR)/towners.o: $(GLOBALDEPS)  Source/towners.cpp
	$(CPP) -c  Source/towners.cpp -o $(OBJDIR)/towners.o $(CXXFLAGS)
$(OBJDIR)/track.o: $(GLOBALDEPS)  Source/track.cpp
	$(CPP) -c  Source/track.cpp -o $(OBJDIR)/track.o $(CXXFLAGS)
$(OBJDIR)/trigs.o: $(GLOBALDEPS)  Source/trigs.cpp
	$(CPP) -c  Source/trigs.cpp -o $(OBJDIR)/trigs.o $(CXXFLAGS)
$(OBJDIR)/wave.o: $(GLOBALDEPS)  Source/wave.cpp
	$(CPP) -c  Source/wave.cpp -o $(OBJDIR)/wave.o $(CXXFLAGS)

#Main
$(OBJDIR)/dx.o: $(GLOBALDEPS) SourceX/dx.cpp
	$(CPP) -c SourceX/dx.cpp -o $(OBJDIR)/dx.o $(CXXFLAGS)
$(OBJDIR)/misc.o: $(GLOBALDEPS) SourceX/miniwin/misc.cpp
	$(CPP) -c SourceX/miniwin/misc.cpp -o $(OBJDIR)/misc.o $(CXXFLAGS)
$(OBJDIR)/misc_io.o: $(GLOBALDEPS) SourceX/miniwin/misc_io.cpp
	$(CPP) -c SourceX/miniwin/misc_io.cpp -o $(OBJDIR)/misc_io.o $(CXXFLAGS)
$(OBJDIR)/misc_msg.o: $(GLOBALDEPS) SourceX/miniwin/misc_msg.cpp
	$(CPP) -c SourceX/miniwin/misc_msg.cpp -o $(OBJDIR)/misc_msg.o $(CXXFLAGS)
$(OBJDIR)/misc_dx.o: $(GLOBALDEPS) SourceX/miniwin/misc_dx.cpp
	$(CPP) -c SourceX/miniwin/misc_dx.cpp -o $(OBJDIR)/misc_dx.o $(CXXFLAGS)
$(OBJDIR)/rand.o: $(GLOBALDEPS) SourceX/miniwin/rand.cpp
	$(CPP) -c SourceX/miniwin/rand.cpp -o $(OBJDIR)/rand.o $(CXXFLAGS)
$(OBJDIR)/thread.o: $(GLOBALDEPS) SourceX/miniwin/thread.cpp
	$(CPP) -c SourceX/miniwin/thread.cpp -o $(OBJDIR)/thread.o $(CXXFLAGS)
$(OBJDIR)/dsound.o: $(GLOBALDEPS) SourceX/miniwin/dsound.cpp
	$(CPP) -c SourceX/miniwin/dsound.cpp -o $(OBJDIR)/dsound.o $(CXXFLAGS)
$(OBJDIR)/ddraw.o: $(GLOBALDEPS) SourceX/miniwin/ddraw.cpp
	$(CPP) -c SourceX/miniwin/ddraw.cpp -o $(OBJDIR)/ddraw.o $(CXXFLAGS)
$(OBJDIR)/sound.o: $(GLOBALDEPS) SourceX/sound.cpp
	$(CPP) -c SourceX/sound.cpp -o $(OBJDIR)/sound.o $(CXXFLAGS)
$(OBJDIR)/storm.o: $(GLOBALDEPS) SourceX/storm/storm.cpp
	$(CPP) -c SourceX/storm/storm.cpp -o $(OBJDIR)/storm.o $(CXXFLAGS)
$(OBJDIR)/storm_net.o: $(GLOBALDEPS) SourceX/storm/storm_net.cpp
	$(CPP) -c SourceX/storm/storm_net.cpp -o $(OBJDIR)/storm_net.o $(CXXFLAGS)
$(OBJDIR)/storm_dx.o: $(GLOBALDEPS) SourceX/storm/storm_dx.cpp
	$(CPP) -c SourceX/storm/storm_dx.cpp -o $(OBJDIR)/storm_dx.o $(CXXFLAGS)
$(OBJDIR)/abstract_net.o: $(GLOBALDEPS) SourceX/dvlnet/abstract_net.cpp
	$(CPP) -c SourceX/dvlnet/abstract_net.cpp -o $(OBJDIR)/abstract_net.o $(CXXFLAGS)
$(OBJDIR)/loopback.o: $(GLOBALDEPS) SourceX/dvlnet/loopback.cpp
	$(CPP) -c SourceX/dvlnet/loopback.cpp -o $(OBJDIR)/loopback.o $(CXXFLAGS)
$(OBJDIR)/packet.o: $(GLOBALDEPS) SourceX/dvlnet/packet.cpp
	$(CPP) -c SourceX/dvlnet/packet.cpp -o $(OBJDIR)/packet.o $(CXXFLAGS)
$(OBJDIR)/base.o: $(GLOBALDEPS) SourceX/dvlnet/base.cpp
	$(CPP) -c SourceX/dvlnet/base.cpp -o $(OBJDIR)/base.o $(CXXFLAGS)
$(OBJDIR)/frame_queue.o: $(GLOBALDEPS) SourceX/dvlnet/frame_queue.cpp
	$(CPP) -c SourceX/dvlnet/frame_queue.cpp -o $(OBJDIR)/frame_queue.o $(CXXFLAGS)
$(OBJDIR)/tcp_client.o: $(GLOBALDEPS) SourceX/dvlnet/tcp_client.cpp
	$(CPP) -c SourceX/dvlnet/tcp_client.cpp -o $(OBJDIR)/tcp_client.o $(CXXFLAGS)
$(OBJDIR)/tcp_server.o: $(GLOBALDEPS) SourceX/dvlnet/tcp_server.cpp
	$(CPP) -c SourceX/dvlnet/tcp_server.cpp -o $(OBJDIR)/tcp_server.o $(CXXFLAGS)
$(OBJDIR)/udp_p2p.o: $(GLOBALDEPS) SourceX/dvlnet/udp_p2p.cpp
	$(CPP) -c SourceX/dvlnet/udp_p2p.cpp -o $(OBJDIR)/udp_p2p.o $(CXXFLAGS)
$(OBJDIR)/credits.o: $(GLOBALDEPS) SourceX/DiabloUI/credits.cpp
	$(CPP) -c SourceX/DiabloUI/credits.cpp -o $(OBJDIR)/credits.o $(CXXFLAGS)
$(OBJDIR)/diabloui.o: $(GLOBALDEPS) SourceX/DiabloUI/diabloui.cpp
	$(CPP) -c SourceX/DiabloUI/diabloui.cpp -o $(OBJDIR)/diabloui.o $(CXXFLAGS)
$(OBJDIR)/dialogs.o: $(GLOBALDEPS) SourceX/DiabloUI/dialogs.cpp
	$(CPP) -c SourceX/DiabloUI/dialogs.cpp -o $(OBJDIR)/dialogs.o $(CXXFLAGS)
$(OBJDIR)/mainmenu.o: $(GLOBALDEPS) SourceX/DiabloUI/mainmenu.cpp
	$(CPP) -c SourceX/DiabloUI/mainmenu.cpp -o $(OBJDIR)/mainmenu.o $(CXXFLAGS)
$(OBJDIR)/progress.o: $(GLOBALDEPS) SourceX/DiabloUI/progress.cpp
	$(CPP) -c SourceX/DiabloUI/progress.cpp -o $(OBJDIR)/progress.o $(CXXFLAGS)
$(OBJDIR)/selconn.o: $(GLOBALDEPS) SourceX/DiabloUI/selconn.cpp
	$(CPP) -c SourceX/DiabloUI/selconn.cpp -o $(OBJDIR)/selconn.o $(CXXFLAGS)
$(OBJDIR)/selgame.o: $(GLOBALDEPS) SourceX/DiabloUI/selgame.cpp
	$(CPP) -c SourceX/DiabloUI/selgame.cpp -o $(OBJDIR)/selgame.o $(CXXFLAGS)
$(OBJDIR)/selhero.o: $(GLOBALDEPS) SourceX/DiabloUI/selhero.cpp
	$(CPP) -c SourceX/DiabloUI/selhero.cpp -o $(OBJDIR)/selhero.o $(CXXFLAGS)
$(OBJDIR)/title.o: $(GLOBALDEPS) SourceX/DiabloUI/title.cpp
	$(CPP) -c SourceX/DiabloUI/title.cpp -o $(OBJDIR)/title.o $(CXXFLAGS)
$(OBJDIR)/main.o: $(GLOBALDEPS) SourceX/main.cpp
	$(CPP) -c SourceX/main.cpp -o $(OBJDIR)/main.o $(CXXFLAGS)


#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
all	:	$(BINDIR)/$(OUTPUT).pfs0 $(BINDIR)/$(OUTPUT).nro

$(BINDIR)/$(OUTPUT).pfs0	:	$(BINDIR)/$(OUTPUT).nso

$(BINDIR)/$(OUTPUT).nso	:	$(BINDIR)/$(OUTPUT).elf

ifeq ($(strip $(NO_NACP)),)
$(BINDIR)/$(OUTPUT).nro	:	$(BINDIR)/$(OUTPUT).elf $(BINDIR)/$(OUTPUT).nacp
else
$(BINDIR)/$(OUTPUT).nro	:	$(BINDIR)/$(OUTPUT).elf
endif

$(BINDIR)/$(OUTPUT).elf	:	$(OFILES)

$(OFILES_SRC)	: $(HFILES_BIN)

# end of Makefile ...
