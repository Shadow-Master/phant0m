#!/usr/bin/perl -w
#Shellcode obfuscator, for linux only as of now.
# Brought to you by Shadow-Master. 
#  @Shadow-Master on #offtopicsec  irc.freenode.net
# Hopefully a windows version will come soon.
# Copyright 2012 by Shadow-Master

	# This program is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License
    # along with this program.  If not, see <http://www.gnu.org/licenses

#thanks to trillian_ from #offsec and bwall , kamsky, and lucidnight, PuN1sh3r from #offtopicsec

#TODO:
#	Add dereferencing on the right side of the instruction mov eax, [ebx +4].
#   Add Line-by-line and framebased ASM obfuscation.

#     ('-.      .-')   _   .-')                      ('-. .-.              .-')   .-') _     (`\ .-') /` _  .-')           .-') _     ('-.  _  .-')                
#    ( OO ).-. ( OO ).( '.( OO )_                   ( OO )  /             ( OO ).(  OO) )     `.( OO ),'( \( -O )         (  OO) )  _(  OO)( \( -O )               
#    / . --. /(_)---\_),--.   ,--.)        ,----.   ,--. ,--..-'),-----. (_)---\_)     '._ ,--./  .--.   ,------.  ,-.-') /     '._(,------.,------.               
#    | \-.  \ /    _ | |   `.'   |        '  .-./-')|  | |  ( OO'  .-.  '/    _ ||'--...__)|      |  |   |   /`. ' |  |OO)|'--...__)|  .---'|   /`. '              
#  .-'-'  |  |\  :` `. |         |        |  |_( O- )   .|  /   |  | |  |\  :` `.'--.  .--'|  |   |  |,  |  /  | | |  |  \'--.  .--'|  |    |  /  | |              
#   \| |_.'  | '..`''.)|  |'.'|  |        |  | .--, \       \_) |  |\|  | '..`''.)  |  |   |  |.'.|  |_) |  |_.' | |  |(_/   |  |  (|  '--. |  |_.' |              
#    |  .-.  |.-._)   \|  |   |  |       (|  | '. (_/  .-.  | \ |  | |  |.-._)   \  |  |   |         |   |  .  '.',|  |_.'   |  |   |  .--' |  .  '.'              
#    |  | |  |\       /|  |   |  |        |  '--'  ||  | |  |  `'  '-'  '\       /  |  |   |   ,'.   |   |  |\  \(_|  |      |  |   |  `---.|  |\  \               
#  .-.-.-')--' `-----' `--'   `--.-')    ('-.-.-.-' ('-. `--'_ .-')-_--'  `-----'   `-(`\ .-')'/` '--'   _--'.-')' `--'('-.  `--'.-')---.-')`_-' '-('-.  _  .-')   
#  \  ( OO )                    ( OO ). ( OO )  /  ( OO ).-.( (  OO) )                 `.( OO ),'       ( '.( OO )_   ( OO ).-. ( OO ).(  OO) )  _(  OO)( \( -O )  
#   ;-----.\  ,--.   ,--.      (_)---\_),--. ,--.  / . --. / \     .'_  .-'),-----. ,--./  .--.          ,--.   ,--.) / . --. /(_)---\_)     '._(,------.,------.  
#   | .-.  |   \  `.'  /       /    _ | |  | |  |  | \-.  \  ,`'--..._)( OO'  .-.  '|      |  |    .-')  |   `.'   |  | \-.  \ /    _ ||'--...__)|  .---'|   /`. ' 
#   | '-' /_).-')     /        \  :` `. |   .|  |.-'-'  |  | |  |  \  '/   |  | |  ||  |   |  |, _(  OO) |         |.-'-'  |  |\  :` `.'--.  .--'|  |    |  /  | | 
#   | .-. `.(OO  \   /          '..`''.)|       | \| |_.'  | |  |   ' |\_) |  |\|  ||  |.'.|  |_|,------.|  |'.'|  | \| |_.'  | '..`''.)  |  |  (|  '--. |  |_.' | 
#   | |  \  ||   /  /\_        .-._)   \|  .-.  |  |  .-.  | |  |   / :  \ |  | |  ||         |  '------'|  |   |  |  |  .-.  |.-._)   \  |  |   |  .--' |  .  '.' 
#   | '--'  /`-./  /.__)       \       /|  | |  |  |  | |  | |  '--'  /   `'  '-'  '|   ,'.   |          |  |   |  |  |  | |  |\       /  |  |   |  `---.|  |\  \  
#   `------'   `--'             `-----' `--' `--'  `--' `--' `-------'      `-----' '--'   '--'          `--'   `--'  `--' `--' `-----'   `--'   `------'`--' '--' 
use strict;
use Term::ANSIColor;
use Getopt::Long;
use File::Basename;

#------------------------------------------------------------
# Set the vars my script uses.
#------------------------------------------------------------

my $banner ="\n\n".
			"    _ (`-.  ('-. .-.   ('-.         .-') _  .-') _             _   .-')\n".    
			"   ( (OO  )( OO )  /  ( OO ).-.    ( OO ) )(  OO) )           ( '.( OO )_ \n". 
			"  _.`     \,--. ,--.  / . --. /,--./ ,--,' /     '._   .----.  ,--.   ,--.)\n".
			"(__...--''|  | |  |  | \\-.  \\ |   \\ |  |\\ |'--...__) /  ..  \\ |   `.'   | \n".
			" |  /  | ||   .|  |.-'-'  |  ||    \\|  | )'--.  .--'.  /  \\  .|         | \n".
			" |  |_.' ||       | \\| |_.'  ||  .     |/    |  |   |  |  '  ||  |'.'|  | \n".
			" |  .___.'|  .-.  |  |  .-.  ||  |\\    |     |  |   '  \\  /  '|  |   |  | \n".
			" |  |     |  | |  |  |  | |  ||  | \\   |     |  |    \\  `'  / |  |   |  | \n".  
			" `--'     `--' `--'  `--' `--'`--'  `--'     `--'     `---''  `--'   `--' \n";
	$banner .= " \t+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+\n".
              " \t|B|y| |S|h|a|d|o|w|-|M|a|s|t|e|r|\n".
              " \t+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+\n";

my ($EAX, $EBX, $ECX, $EDX, $ESP, $EBP, $EDI, $ESI);					#Vars to keep the current state of the registers
my ($AH, $AL, $BH, $BL, $CH, $CL, $DH, $DL);							#^
my ($AX, $BX, $CX, $DX);												#^
my @STACK;													#My stack frame...
my ($OF, $SF, $ZF) = (0,0,0);
#OF = Overflow flag == If the operation Overflows past 32 bits or whatever, set this flag, else unset.  *NOT REALLY USED*
#SF = Sign flag 	== If the number turned negative, set this flag, else unset.
#ZF = Zero flag		== If the operation results in Zero, it's set, else unset.

#loop {label} - dec ECX && jmp label if ECX > 0


# <@WiK> i want to use your script, pass it som shellcode and have it pour  thought my shellcode and find smaller versions for hte fuctions
# <@WiK> like if i do a add eax, 0000001
# <@WiK> the script should replace it with inc eax

#----------------------------------------------
# all the above should be a hash table, but when I started, I did not know what that was.
# Now I'm too lazy to fix, especially because it works.
#----------------------------------------------



my @REG32 = ('EAX', 'EBX', 'ECX', 'EDX', 'ESP', 'EBP', 'EDI', 'ESI');   #32 bit registers to search for
my @REG16 = ('AH', 'AL', 'BH', 'BL', 'CH', 'CL', 'DH','DL');			#16 bit registers to search
#----------------------------------------------
#These are unused right now, but I may end up using them.
#----------------------------------------------


my @SPECIAL = ('INT');													#Special CMDs to parse, maybe add more? popad, pushad etc...
#Really want to change this LINENUMBER to something else, just don't know what
my (@ASM, @LINES, %LINENUMBER , $NEWASM , $FILE, $NEWFILE, $MATCH, $INTS, $LASTCMD);					#Various Vars to use, as of now not all are used.
my $tellcount = 0;			# var to keep the colors easier to read.
my $FRAMECOUNT = 0;			# number of int 0x80's parsed so far.
my $OFFSET = 16; 			# how many times was ESP pushed to. 16 is base
my $fd = 253;         #file descripter for sys calls returned into eax.
my $currentline = 0;
my ($interactive, $createfrm, $verbose, $readfrm, $generatefrm, $linebyline, $help);		# args with default values
$interactive = 0;
$verbose = 0;
$help = 0;
$readfrm = '';
$generatefrm ='';
$createfrm = '';
$linebyline = '';
#----------------------------------------------
#All of the above will end up being used for various purposes...
#----------------------------------------------



#------------------------------------------------------------
# grab the arguments and deal with them. 
#------------------------------------------------------------
GetOptions('v|verbose+' => \$verbose,
			'i|interactive' => \$interactive,
			'r|readframe=s' => \$readfrm,
			'g|generatecode=s' => \$generatefrm,
			'c|createframe=s' => \$createfrm,
			'l|linebyline=s' => \$linebyline,
			'h|help' => \$help);  #interactive, ASM file, verbose, read .frm, obfuscate .frm ...
		
#----------------------------------------------
#  Add check for improper usage...
#----------------------------------------------
if (!($linebyline xor $createfrm xor $generatefrm xor $readfrm xor $interactive xor $help))
{
	&Usage("Please select one and only one mode!");
}

#----------------------------------------------
# If we got here, then a good selection was made.
#----------------------------------------------
print color('bold red'),"$banner\n", color('reset');

# Initialize Register vars
$EAX = 3135237841;  #Since shellcode is position independant,
$EBX = 3135237841;  #Set all registers to one val.  0xbadfeed1  any changes will be assumed to be generated from the code and will be dealt with.
$ECX = 3135237841;
$EDX = 3135237841;
$ESP = 3735928320;					#  <<--  0xDEADBE00 as a location marker.
$EBP = 3135237841;
$EDI = 3135237841;
$ESI = 3135237841;
&tellme("All registers start as markers!",2,1);
&tellme("ESP is 0xDEADBE00 (3735928320) as a location marker.",2,1);
&tellme("All other are 0xBADFEED1 (3135237841).",2,1);
print "\n\n";
&update32('EAX');
&update32('EBX');
&update32('ECX');
&update32('EDX');


#----------------------------------------------
# Figure out which option was picked and jump to the corresponding sub.
#----------------------------------------------

if ($createfrm ne '')
{
	&createframe($createfrm);
	&tellme("Parsing done!",1,1);
}
elsif ($interactive)
{
	&interactive;
	&tellme("Interactive mode done!",1,1);
	&status;
}
elsif ($readfrm ne '')
{
	&readframe($readfrm);
	&tellme("Reading frame done!",1,1);
	&status;
}
elsif ($generatefrm ne '')
{
	&generateASM($generatefrm);
	&tellme("Generating frame done!",1,1);
	&status;
}
elsif ($linebyline ne '')
{
	&linebyline($linebyline);
	&status;
}
elsif ($help)
{
	&Usage("Help screen:");
}

#cmd's	
{
sub NONE
{
	&tellme("Entered NONE.",4,1); #Not really used...
}
sub SPECIAL
{
	# Input: The special CMD that triggered the sub.
	# Action: Saves a framestate.

	&tellme("Entered SPECIAL with \33[35mCMD:\33[34m $_[0]",4,1);
	&saveframe($_[0]);
}
sub INT
{
	# Input: INT 0x80.
	# Action: Saves a framestate and checks what syscall it is.
	#		  If the syscall returns a file descripter into a reg,
	#         it is taken into account.

	&tellme("Entered INT with \33[35mCMD:\33[34m $_[0] $_[1].",4,1);
	&saveframe($_[0]);
	if ($EAX == 102 or $EAX == 384)  # open syscall... i need to add more of these checks...
	{
		&tellme("SYSCALL returns a file descripter into EAX.",4,1);
		$EAX = $fd;
		&update32('EAX');
	}
}
sub DEREF #deref'd vals cant set flags...
{
	#Input: A line that needs to be dereferenced (eg. mov [eax +5], bl
	
	my $newcmd = $_[0]; # the cmd to be parsed that was passed in
	my $newval = 0;     # what the new value will be after the change
	my ($action, $reg, $byte, $val); #regex parsed values...
	my $stackval;  #Where is the deref going to occur
	my ($firstel, $secondel, $joined, $valsize);  # vars for the stack elements, single and joined, and the byte count of the val from the regex
	my $changed; # the specific string that will be changed.
	
	
	&tellme("Deref'ed CMD found. Attmepting to deref...",2,1);
	&tellme("CMD: => \33[35m$newcmd\33[33m<=",2,2);
	
	
	$newcmd =~ m/([\S]+)[\s]*[\[][\s]*([^\+]+)\+[\s]*([\S^\]]+)[\s]*[\]][\s]*,[\s]*([^;\s]+)[;]?/;   #regex to remove the stuff we need
	#$LINE =~ m/(?<instruction>[\S]+)[\s]*[\[][\s]*(?<reg>[^\+]+)\+[\s]*(?<offset>[\S^\]]+)[\s]*[\]][\s]*,[\s]*(?<value>[^;\s]+)[;]?/;
	$action = uc(&trim($1));  # sort the values
	$reg = &trim($2); 		  # ^
	$byte = &trim($3);
	$val = &trim($4);
	&tellme("Instruction: >\33[31m$action\33[33m< Register: >\33[31m$reg\33[33m< Offset: >\33[31m$byte\33[33m< Value: >\33[31m$val\33[33m<",3,3);
	
	
	$stackval = int(&returnvalueof('ESP') - &returnvalueof($reg));  # (current esp + placeholder) - the reg's placeholder will get us what offset the LEA was used at that we can then use to process.
	$stackval += int($byte / 4);       # for each 4 bytes in, inc the stack element by one.
	$byte %= 4;   # then reset the byte to which we really want.
	&tellme("Stack Element Number: \33[34m$stackval\33[33m,\33[32m $byte\33[33m byte(s) in.",3,3);
	
	
	$firstel = sprintf("%08X", $STACK[$stackval]); # grab into a var with formatting
	$secondel = sprintf("%08X", $STACK[$stackval + 1]);
	$joined = $firstel.$secondel;  # join them so we can work with large vals.
	&tellme("The joined stack value is: \33[36m$joined.",4,3);
	
	# now lets figure out how much editing needs to be done.
	# using eax as an example
	#eax = 4 bytes(8 nybbles), ax =2(4) al,ah = 1(2) 
	#these checks all tell me which value was chosen.
	if (uc(substr($val,-1,1)) eq "L" or uc(substr($val,-1,1)) eq "H") # al, or ah
	{
		$valsize = 2;  #the lower and higher *nybbles*
	}
	elsif (uc(substr($val,-1,1)) eq "X" and uc(substr($val,0,1)) ne "E") #ax
	{
		$valsize = 4; #the words in nybbles
	}
	elsif (uc(substr($val,-1,1)) eq "X" and uc(substr($val,0,1)) eq "E") #eax
	{
		$valsize = 8; # the DWORDS
	}
	else 	#any other value is assumed to be a four byte value.												
	{
		$valsize = 8; # all other vals, including, esp, esi, edi, ebp are four bytes...
	}
	&tellme("The sub will edit a byte count of \33[34m$valsize\33[33m from the string.", 4,3);
	
	$changed = substr($joined,$byte,$valsize);  # this grabs out the string to process. from the beginning of $byte(the val to start at) to the amount of nybbles
	&tellme("Changing string is: \33[32m$changed.",4,3);
	$changed = hex $changed;  # lets get the decimal value of that string.
		if ($action eq 'MOV')
		{
			$newval = sprintf("%0".$valsize."X", &returnvalueof($val));  #replace it. very easy to do a mov.
		}
		elsif ($action eq 'XOR')
		{
			$newval = sprintf("%0".$valsize."X", ($changed ^ &returnvalueof($val))); #xor the old string against the value then format it correctly for input.
		}
		elsif ($action eq 'OR')
		{
			$newval = sprintf("%0".$valsize."X", ($changed | &returnvalueof($val))); #or the old string against the value then format it correctly for input.
		}
		elsif ($action eq 'AND')
		{
			$newval = sprintf("%0".$valsize."X", ($changed & &returnvalueof($val))); #and the old string against the value then format it correctly for input.
		}
		elsif ($action eq 'ADD')
		{
			$newval = sprintf("%0".$valsize."X", (($changed + &returnvalueof($val)) % ((2**$valsize)-1))); #add the old string against the value then format it correctly for input.
		}																								  # then mod that value to make sure if we get an overflow we can still place that val back.
		elsif ($action eq 'SUB')
		{
			$newval = sprintf("%0".$valsize."X", (abs($changed - &returnvalueof($val)) % ((2**$valsize)-1))); #subtract the two vals and return the absolute val, which will happen in an overflow...
		}
		&tellme("The value it will be changed into is: \33[34m$newval.",5,3);
		
		
		if ($byte == 0)  # the first byte of the string was changed
		{
			$joined = $newval.substr($joined,$byte,(16 - $valsize));  #join the new value to the rest of the string.
		}
		else  # we edited the middle of the string...
		{
			#combine     beginning until edit       edit      after edit to the end
			$joined = substr($joined,0, $valsize).$newval.substr($joined,$valsize+length($newval));
		}
		&tellme("The new stack values will be: \33[36m$joined.",4,3);
		
		$STACK[$stackval] = hex(substr($joined,0,8));  #place these into the stack..
		&tellme("\$STACK[$stackval]: \33[36m$STACK[$stackval].",5,3);
		$STACK[$stackval + 1] = hex(substr($joined,8));
		&tellme("\$STACK[".($stackval+1)."]: \33[36m".$STACK[$stackval+1].".",5,3);
}
sub CDQ 
{
	# no input, this checks if eax is negative or overflowed and sets edx accordingly.
	# if eax is within 32 bytes, it will zero out edx.
	&tellme("Entered \33[34m CDQ",4,1);
	if (($EAX >-1) and ($EAX < 4294967296))
	{
		$EDX =0;
		&update32('EDX');
	}
	else
	{
		$EDX =1;
		&update32('EDX');
	}
	&tellme("EDX is now: \33[36m $EDX.",4,3); 
}
sub AND
{
	# input: "AND", {reg}, {val}
	# action: AND's the reg against the returnvalueof(val)
	&tellme("\33[35mCMD:\33[34m $_[0] \33[32m$_[1], $_[2]",4,1);
	if (uc($_[1]) eq 'EAX')
		{
			$EAX = ($EAX & &returnvalueof($_[2]));
			&update32('EAX');
		}
		elsif (uc($_[1]) eq 'EBX')
		{
			$EBX = ($EBX & &returnvalueof($_[2]));
			&update32('EBX');
		}
		elsif (uc($_[1]) eq 'ECX')
		{
			$ECX = ($ECX & &returnvalueof($_[2]));
			&update32('ECX');
		}
		elsif (uc($_[1]) eq 'EDX')
		{
			$EDX = ($EDX & &returnvalueof($_[2]));
			&update32('EDX');
		}
		elsif (uc($_[1]) eq 'ESP')
		{
			$ESP = ($ESP & &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'EBP')
		{
			$EBP = ($EBP & &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'ESI')
		{
			$ESI = ($ESI & &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'EDI')
		{
			$EDI = ($EDI & &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'AX')
		{
			$AX = ($AX & &returnvalueof($_[2]));
			&update16('AX');
		}
		elsif (uc($_[1]) eq 'BX')
		{
			$BX = ($BX & &returnvalueof($_[2]));
			&update16('BX');
		}
		elsif (uc($_[1]) eq 'CX')
		{
			$CX = ($CX & &returnvalueof($_[2]));
			&update16('CX');
		}
		elsif (uc($_[1]) eq 'DX')
		{
			$DX = ($DX & &returnvalueof($_[2]));
			&update16('DX');
		}
		elsif (uc($_[1]) eq 'AL')
		{
			$AL = ($AL & &returnvalueof($_[2]));
			&update8('AL');
		}
		elsif (uc($_[1]) eq 'AH')
		{
			$AH = ($AH & &returnvalueof($_[2]));
			&update8('AH');
		}
		elsif (uc($_[1]) eq 'BL')
		{
			$BL = ($BL & &returnvalueof($_[2]));
			&update8('BL');
		}
		elsif (uc($_[1]) eq 'BH')
		{
			$BH = ($BH & &returnvalueof($_[2]));
			&update8('BH');
		}
		elsif (uc($_[1]) eq 'CL')
		{
			$CL = ($CL & &returnvalueof($_[2]));
			&update8('CL');
		}
		elsif (uc($_[1]) eq 'CH')
		{
			$CH = ($CH & &returnvalueof($_[2]));
			&update8('CH');
		}
		elsif (uc($_[1]) eq 'DL')
		{
			$DL = ($DL & &returnvalueof($_[2]));
			&update8('DL');
		}
		elsif (uc($_[1]) eq 'DH')
		{
			$DH = ($DH & &returnvalueof($_[2]));
			&update8('DH');
		}
		&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
		&updateflags($_[1], $_[2]);
}
sub JMP
{
	&tellme("\33[35mCMD:\33[34m \33[32m$_[0] $_[1]",4,1);
	my $type = uc($_[0]);
	my $label = $_[1];
	if ($type eq 'JMP')
	{
		$currentline = $LINENUMBER{$label.":"};
		&tellme("JMP taken...",3,2);
	}
	elsif ($type eq 'JS')
	{
		if($SF == 1)
		{
			$currentline = $LINENUMBER{$label.":"};
			&tellme("JMP taken...",3,2);
		}
		else
		{
			&tellme("JMP not taken...",3,2);
		}
	}
	elsif ($type eq 'JNS')
	{
		if($SF == 0)
		{
			$currentline = $LINENUMBER{$label.":"};
			&tellme("JMP taken...",3,2);
		}
		else
		{
			&tellme("JMP not taken...",3,2);
		}
	}
	elsif ($type eq 'JZ' or $type eq 'JE')
	{
		if($ZF == 1)
		{
			$currentline = $LINENUMBER{$label.":"};
			&tellme("JMP taken...",3,2);
		}
		else
		{
			&tellme("JMP not taken...",3,2);
		}
	}
	elsif ($type eq 'JNZ' or $type eq 'JNE')
	{
		if($ZF == 0)
		{
			$currentline = $LINENUMBER{$label.":"};
			&tellme("JMP taken...",3,2);
		}
		else
		{
			&tellme("JMP not taken...",3,2);
		}
	}
}
sub CALL
{
	&tellme("Entered CALL. Not implemented yet. Code may fail...",4,0);
	&tellme("\33[35mCMD:\33[34m \33[32m$_[0] $_[1]",4,1);
}
sub TEST  #used to set some flags
{
	&tellme("\33[35mCMD:\33[34m $_[0] \33[32m$_[1], $_[2]",4,1);
	my $flagval = ($_[1] & $_[2]);
	$SF = 0;
	$ZF = 0;
	$OF = 0;
	$ZF = 1 if ($flagval == 0);
	$SF = 1 if (((2**(&size($_[1]))-1) & &returnvalueof($_[1])) == 0);
}
sub CMP
{
	&tellme("\33[35mCMD:\33[34m \33[32m$_[0] $_[1]",4,1);
	$ZF = 0;
	if (&returnvalueof($_[1]) - &returnvalueof($_[2]) == 0)
	{
		$ZF = 1;
		&tellme("Zero flag set.",4,2);
	}
}
sub MOV
{
	# input: "MOV", {reg}, {val}
	# action: MOV's the val into reg
	&tellme("\33[35mCMD:\33[34m $_[0] \33[32m$_[1], $_[2]",4,1);
	if (uc($_[1]) eq 'EAX')
		{
			$EAX = (&returnvalueof($_[2]));
			&update32('EAX');
		}
		elsif (uc($_[1]) eq 'EBX')
		{
			$EBX = (&returnvalueof($_[2]));
			&update32('EBX');
		}
		elsif (uc($_[1]) eq 'ECX')
		{
			$ECX = (&returnvalueof($_[2]));
			&update32('ECX');
		}
		elsif (uc($_[1]) eq 'EDX')
		{
			$EDX = (&returnvalueof($_[2]));
			&update32('EDX');
		}
		elsif (uc($_[1]) eq 'ESP')
		{
			$ESP = (&returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'EBP')
		{
			$EBP = (&returnvalueof($_[2]));
		}
				elsif (uc($_[1]) eq 'ESI')
		{
			$ESI = (&returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'EDI')
		{
			$EDI = (&returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'ESI')
		{
			$ESI = (&returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'AX')
		{
			$AX = (&returnvalueof($_[2]));
			&update16('AX');
		}
		elsif (uc($_[1]) eq 'BX')
		{
			$BX = (&returnvalueof($_[2]));
			&update16('BX');
		}
		elsif (uc($_[1]) eq 'CX')
		{
			$CX = (&returnvalueof($_[2]));
			&update16('CX');
		}
		elsif (uc($_[1]) eq 'DX')
		{
			$DX = (&returnvalueof($_[2]));
			&update16('DX');
		}
		elsif (uc($_[1]) eq 'AL')
		{
			$AL = (&returnvalueof($_[2]));
			&update8('AL');
		}
		elsif (uc($_[1]) eq 'AH')
		{
			$AH = (&returnvalueof($_[2]));
			&update8('AH');
		}
		elsif (uc($_[1]) eq 'BL')
		{
			$BL = (&returnvalueof($_[2]));
			&update8('BL');
		}
		elsif (uc($_[1]) eq 'BH')
		{
			$BH = (&returnvalueof($_[2]));
			&update8('BH');
		}
		elsif (uc($_[1]) eq 'CL')
		{
			$CL = (&returnvalueof($_[2]));
			&update8('CL');
		}
		elsif (uc($_[1]) eq 'CH')
		{
			$CH = (&returnvalueof($_[2]));
			&update8('CH');
		}
		elsif (uc($_[1]) eq 'DL')
		{
			$DL = (&returnvalueof($_[2]));
			&update8('DL');
		}
		elsif (uc($_[1]) eq 'DH')
		{
			$DH = (returnvalueof($_[2]));
			&update8('DH');
		}
		&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
		&updateflags($_[1], $_[2]);
}
sub XOR
{
	# input: "XOR", {reg}, {val}
	# action: XOR's the reg against the value
	&tellme("\33[35mCMD:\33[34m $_[0] \33[32m$_[1], $_[2]",4,1);
	if (uc($_[1]) eq 'EAX')
		{
			$EAX = ($EAX ^ &returnvalueof($_[2]));
			&update32('EAX');
		}
		elsif (uc($_[1]) eq 'EBX')
		{
			$EBX = ($EBX ^ &returnvalueof($_[2]));
			&update32('EBX');
		}
		elsif (uc($_[1]) eq 'ECX')
		{
			$ECX = ($ECX ^ &returnvalueof($_[2]));
			&update32('ECX');
		}
		elsif (uc($_[1]) eq 'EDX')
		{
			$EDX = ($EDX ^ &returnvalueof($_[2]));
			&update32('EDX');
		}
		elsif (uc($_[1]) eq 'ESP')
		{
			$ESP = ($ESP ^ &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'EBP')
		{
			$EBP = ($EBP ^ &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'ESI')
		{
			$ESI = ($ESI ^ &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'EDI')
		{
			$EDI = ($EDI ^ &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'AX')
		{
			$AX = ($AX ^ &returnvalueof($_[2]));
			&update16('AX');
		}
		elsif (uc($_[1]) eq 'BX')
		{
			$BX = ($BX ^ &returnvalueof($_[2]));
			&update16('BX');
		}
		elsif (uc($_[1]) eq 'CX')
		{
			$CX = ($CX ^ &returnvalueof($_[2]));
			&update16('CX');
		}
		elsif (uc($_[1]) eq 'DX')
		{
			$DX = ($DX ^ &returnvalueof($_[2]));
			&update16('DX');
		}
		elsif (uc($_[1]) eq 'AL')
		{
			$AL = ($AL ^ &returnvalueof($_[2]));
			&update8('AL');
		}
		elsif (uc($_[1]) eq 'AH')
		{
			$AH = ($AH ^ &returnvalueof($_[2]));
			&update8('AH');
		}
		elsif (uc($_[1]) eq 'BL')
		{
			$BL = ($BL ^ &returnvalueof($_[2]));
			&update8('BL');
		}
		elsif (uc($_[1]) eq 'BH')
		{
			$BH = ($BH ^ &returnvalueof($_[2]));
			&update8('BH');
		}
		elsif (uc($_[1]) eq 'CL')
		{
			$CL = ($CL ^ &returnvalueof($_[2]));
			&update8('CL');
		}
		elsif (uc($_[1]) eq 'CH')
		{
			$CH = ($CH ^ &returnvalueof($_[2]));
			&update8('CH');
		}
		elsif (uc($_[1]) eq 'DL')
		{
			$DL = ($DL ^ &returnvalueof($_[2]));
			&update8('DL');
		}
		elsif (uc($_[1]) eq 'DH')
		{
			$DH = ($DH ^ &returnvalueof($_[2]));
			&update8('DH');
		}
		&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
		&updateflags($_[1], $_[2]);
}
sub ADD
{
	# input: "ADD", {reg}, {val}
	# action: ADD's the reg to the value
	&tellme("\33[35mCMD:\33[34m $_[0] \33[32m$_[1], $_[2]",4,1);
		if (uc($_[1]) eq 'EAX')
		{
			$EAX += (&returnvalueof($_[2]));
			$EAX %= 4294967295;
			&update32('EAX');
		}
		elsif (uc($_[1]) eq 'EBX')
		{
			$EBX += (&returnvalueof($_[2]));
			$EBX %= 4294967295;
			&update32('EBX');
		}
		elsif (uc($_[1]) eq 'ECX')
		{
			$ECX += (&returnvalueof($_[2]));
			$ECX %= 4294967295;
			&update32('ECX');
		}
		elsif (uc($_[1]) eq 'EDX')
		{
			$EDX += (&returnvalueof($_[2]));
			$EDX %= 4294967295;
			&update32('EDX');
		}
		elsif (uc($_[1]) eq 'ESP')
		{
			$ESP +=  &returnvalueof($_[2]);
		}
		elsif (uc($_[1]) eq 'EBP')
		{
			$EBP +=  &returnvalueof($_[2]);
		}
				elsif (uc($_[1]) eq 'ESI')
		{
			$ESI +=  &returnvalueof($_[2]);
		}
		elsif (uc($_[1]) eq 'EDI')
		{
			$EDI +=  &returnvalueof($_[2]);
		}
		&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
		&updateflags($_[1], $_[2]);
}
sub SUB
{
	# input: "SUB", {reg}, {val}
	# action: SUB's the val from the reg
	&tellme("\33[35mCMD:\e[34m $_[0] \33[32m$_[1], $_[2]",4,1);
		if (uc($_[1]) eq 'EAX')
		{
			$EAX += (4294967295 - &returnvalueof($_[2]));
			$EAX %= 4294967295;
			&update32('EAX');
		}
		elsif (uc($_[1]) eq 'EBX')
		{
			$EBX += (4294967295 - &returnvalueof($_[2]));
			$EBX %= 4294967295;
			&update32('EBX');
		}
		elsif (uc($_[1]) eq 'ECX')
		{
			$ECX += (4294967295 - &returnvalueof($_[2]));
			$ECX %= 4294967295;
			&update32('ECX');
		}
		elsif (uc($_[1]) eq 'EDX')
		{
			$EDX += (4294967295 - &returnvalueof($_[2]));
			$EDX %= 4294967295;
			&update32('EDX');
		}
		elsif (uc($_[1]) eq 'ESP')
		{
			$ESP +=  &returnvalueof($_[2]);
		}
		elsif (uc($_[1]) eq 'EBP')
		{
			$EBP +=  &returnvalueof($_[2]);
		}
		elsif (uc($_[1]) eq 'ESI')
		{
			$ESI +=  &returnvalueof($_[2]);
		}
		elsif (uc($_[1]) eq 'EDI')
		{
			$EDI +=  &returnvalueof($_[2]);
		}
		&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
		&updateflags($_[1], $_[2]);
}
sub OR
{
	# input: "OR", {reg}, {val}
	# action: OR's the reg against the value
	&tellme("\33[35mCMD:\e[34m $_[0]\33[32m $_[1], $_[2]",4,1);
	if (uc($_[1]) eq 'EAX')
		{
			$EAX = ($EAX | &returnvalueof($_[2]));
			&update32('EAX');
		}
		elsif (uc($_[1]) eq 'EBX')
		{
			$EBX = ($EBX | &returnvalueof($_[2]));
			&update32('EBX');
		}
		elsif (uc($_[1]) eq 'ECX')
		{
			$ECX = ($ECX | &returnvalueof($_[2]));
			&update32('ECX');
		}
		elsif (uc($_[1]) eq 'EDX')
		{
			$EDX = ($EDX | &returnvalueof($_[2]));
			&update32('EDX');
		}
		elsif (uc($_[1]) eq 'ESP')
		{
			$ESP = ($ESP | &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'EBP')
		{
			$EBP = ($EBP | &returnvalueof($_[2]));
		}
				elsif (uc($_[1]) eq 'ESI')
		{
			$ESI = ($ESI | &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'EDI')
		{
			$EDI = ($EDI | &returnvalueof($_[2]));
		}
		elsif (uc($_[1]) eq 'AX')
		{
			$AX = ($AX | &returnvalueof($_[2]));
			&update16('AX');
		}
		elsif (uc($_[1]) eq 'BX')
		{
			$BX = ($BX | &returnvalueof($_[2]));
			&update16('BX');
		}
		elsif (uc($_[1]) eq 'CX')
		{
			$CX = ($CX | &returnvalueof($_[2]));
			&update16('CX');
		}
		elsif (uc($_[1]) eq 'DX')
		{
			$DX = ($DX | &returnvalueof($_[2]));
			&update16('DX');
		}
		elsif (uc($_[1]) eq 'AL')
		{
			$AL = ($AL | &returnvalueof($_[2]));
			&update8('AL');
		}
		elsif (uc($_[1]) eq 'AH')
		{
			$AH = ($AH | &returnvalueof($_[2]));
			&update8('AH');
		}
		elsif (uc($_[1]) eq 'BL')
		{
			$BL = ($BL | &returnvalueof($_[2]));
			&update8('BL');
		}
		elsif (uc($_[1]) eq 'BH')
		{
			$BH = ($BH | &returnvalueof($_[2]));
			&update8('BH');
		}
		elsif (uc($_[1]) eq 'CL')
		{
			$CL = ($CL | &returnvalueof($_[2]));
			&update8('CL');
		}
		elsif (uc($_[1]) eq 'CH')
		{
			$CH = ($CH | &returnvalueof($_[2]));
			&update8('CH');
		}
		elsif (uc($_[1]) eq 'DL')
		{
			$DL = ($DL | &returnvalueof($_[2]));
			&update8('DL');
		}
		elsif (uc($_[1]) eq 'DH')
		{
			$DH = ($DH | &returnvalueof($_[2]));
			&update8('DH');
		}
		&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
		&updateflags($_[1], $_[2]);
}
sub XCHG
{
	# input: "XCHG", {reg}, {val}
	# action: XCHG's the reg with the value
	#I split this up into tw MOV subs instead of coding a seperate XCHG sub.
	&tellme("\33[35mCMD:\e[34m $_[0] \33[32m$_[1], $_[2]",4,1);
	&tellme(uc($_[1]) ." is: \33[36m".&returnvalueof($_[1])."\33[33m, ".uc($_[2])." is: \33\[36m".&returnvalueof($_[2]).".",5,3);
	my $tmpvar = &returnvalueof($_[1]);
	&MOV($_[0], $_[1], $_[2]);
	&MOV($_[0], $_[2], $tmpvar);
	&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1])."\33[33m, ".uc($_[2])." is now: \33\[36m".&returnvalueof($_[2]).".",5,3);
}
sub DOSTACK
{
	# input: "PUSH" or "POP"  {reg} or {val}
	# action: will either push the value to the stack, or update the reg as necessary
	# calls a support sub...
	if (uc($_[0]) eq 'PUSH')
	{
		&tellme("\33[35mCMD:\e[34m $_[0] \33[32m$_[1]",4,1);
		&updatestack('PUSH', &returnvalueof($_[1]));
	}
	else
	{
		&tellme("\33[35mCMD: \33[34m$_[0] \33[32m$_[1]",4,1);
		&updatestack('POP',&trim($_[1]));
	}
}
sub INC
{
	# input: "INC", {reg}
	# action: inc a reg
	&tellme("\33[35mCMD:\e[34m $_[0] \33[32m$_[1]",4,1);
		if (uc($_[1]) eq 'EAX')
		{
			$EAX += 1;
			if ($EAX == 4294967295) # if we have overflowed...
			{
				$EAX = 1;   # dont. :D
			}
			&update32('EAX');
		}
		elsif (uc($_[1]) eq 'EBX')
		{
			$EBX += 1;
			if ($EBX == 4294967295)
			{
				$EBX = 1;
			}
			&update32('EBX');
		}
		elsif (uc($_[1]) eq 'ECX')
		{
			$ECX += 1;
			if ($ECX == 4294967295)
			{
				$ECX = 1;
			}
			&update32('ECX');
		}
		elsif (uc($_[1]) eq 'EDX')
		{
			$EDX += 1;
			if ($EDX == 4294967295)
			{
				$EDX = 1;
			}
			&update32('EDX');
		}
		elsif (uc($_[1]) eq 'ESP')
		{
			$ESP += 1;
		}
		elsif (uc($_[1]) eq 'EBP')
		{
			$EBP += 1;
		}
				elsif (uc($_[1]) eq 'ESI')
		{
			$ESI += 1;
		}
		elsif (uc($_[1]) eq 'EDI')
		{
			$EDI += 1;
		}
		&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
		&updateflags($_[1]);
}
sub DEC
{
	# input: "DEC", {reg}
	# action: DEC's a reg
	&tellme("\33[35mCMD:\e[32m $_[0] \33[32m$_[1]",4,1);
		if (uc($_[1]) eq 'EAX')
		{
			$EAX -= 1;
			&update32('EAX');
		}
		elsif (uc($_[1]) eq 'EBX')
		{
			$EBX -= 1;
			&update32('EBX');
		}
		elsif (uc($_[1]) eq 'ECX')
		{
			$ECX -= 1;
			&update32('ECX');
		}
		elsif (uc($_[1]) eq 'EDX')
		{
			$EDX -= 1;
			&update32('EDX');
		}
		elsif (uc($_[1]) eq 'ESP')
		{
			$ESP -= 1;
		}
		elsif (uc($_[1]) eq 'EBP')
		{
			$EBP -= 1;
		}
		elsif (uc($_[1]) eq 'ESI')
		{
			$ESI -= 1;
		}
		elsif (uc($_[1]) eq 'EDI')
		{
			$EDI -= 1;
		}
	&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
	&updateflags($_[1]);
}
sub LEA
{
	# input: "LEA", {reg}, {reg}
	# action: mov's one reg into another. in my script this is dealt with like a refernece.
	&tellme("\33[35mCMD:\e[32m $_[0] \33[32m $_[1] ,  $_[2]",4,1);
	&MOV($_[0],$_[1], $_[2]);
	&tellme(uc($_[1]) ." is now: \33[36m".&returnvalueof($_[1]).".",5,3);
}
sub LOOP
{
	&tellme("\33[35mCMD:\e[32m $_[0]\33[32m $_[1]",2,1);
	my $label = $_[1];
	&DEC('DEC', 'ECX');
	if(&returnvalueof('ECX') > 0)
	{
		&tellme("Loop taken...",3,2);
		&JMP('JMP', $label);
	}
	else
	{
		&tellme("Loop not taken...",3,2);

	}
}
}
#update subs
{
# ALL UPDATE SUBS ARE TO BE CALLED **AFTER** **AFTER** THE NEW VALUES ARE IN THE REGISTERS!!!
#only the first "if" in each sub is commented since these are all the same...
sub update32  # update the 32 bit registers and therefore update the sixteen and eight bit registers.  <<WORKS!!
{
	&tellme("\33[34m ".$_[0]."\33[33m has changed. Taking that into account.",4,3);
	&tellme("Changing the child registers of\33[34m ".$_[0]."\33[33m now.",4,3);
	if (uc($_[0]) eq 'EAX')
	{
		$AX = $EAX & 65535;  				# Get the lower 16 bits of each register
		$AH = $AX & 65280;					#And further split those
		$AL = $AX & 255;
		&tellme("Child registers of\33[36m EAX\33[33m now changed.",5,3);
	}
	elsif (uc($_[0]) eq 'EBX')
	{
		$BX = $EBX & 65535;  				# Get the lower 16 bits of each register
		$BH = $BX & 65280;					#And further split those
		$BL = $BX & 255;
		&tellme("Child registers of \33[36mEBX\33[33m now changed.",5,3);
	}
	elsif (uc($_[0]) eq 'ECX')
	{
		$CX = $ECX & 65535;  				# Get the lower 16 bits of each register
		$CH = $CX & 65280;					#And further split those
		$CL = $CX & 255;
		&tellme("Child registers of \33[36mECX\33[33m now changed.",5,3);
	}
	elsif (uc($_[0]) eq 'EDX')
	{
		$DX = $EDX & 65535;  				# Get the lower 16 bits of each register
		$DH = $DX & 65280;					#And further split those
		$DL = $DX & 255;
		&tellme("Child registers of \33[36mEDX\33[33m now changed.",5,3);
	}
	else
	{
		&tellme("Invalid update call with: \33[31m".$_[0]."\33[33m!",4,0);
	}
}
sub update16  # update the sixteen then update the 32 to pass the joy
{
	&tellme("\33[35m".$_[0]." \33[33mhas changed. Taking that into account.",4,3);
	if (uc($_[0]) eq 'AX')
	{
		$EAX = $EAX | 65535;          # set the AX bits to all be one
		$EAX = $EAX & ($AX + 4294901760);  # AND (FFFF0000 + $AX) against the  EAX to get the new bits
		$EAX %= 4294967295;
		&update32('EAX');			  # then AND that against the old EAX to update, then update.
	}
	elsif (uc($_[0]) eq 'BX')
	{
		$EBX = $EBX | 65535;
		$EBX = $EBX & ($BX + 4294901760); 
		$EBX %= 4294967295;
		&update32('EBX');
	}
	elsif (uc($_[0]) eq 'CX')
	{
		$ECX = $ECX | 65535;
		$ECX = $ECX & ($CX + 4294901760); 
		$ECX %= 4294967295;		
		&update32('ECX');
	}
	elsif (uc($_[0]) eq 'DX')
	{
		$EDX = $EDX | 65535;
		$EDX = $EDX & ($DX + 4294901760);
		$EDX %= 4294967295;
		&update32('EDX');
	}
	else
	{
		&tellme("Invalid update call with: \33[36m".$_[0]."!",4,0);
	}
}
sub update8   # update the 8 then the 32
{
	&tellme("\33[35m".$_[0]."\33[33m has changed. Taking that into account.",4,3);
	if (uc($_[0]) eq 'AH')
	{
		$EAX = $EAX | 65280;				# set the AH bits to all be one and get those new bits.
		$EAX = ($EAX & ($AH + 4294902015));  #same as 16 but FFFF00FF for higher orders and FFFFFFF00 for lower
		$EAX %= 4294967295;
		&update32('EAX');
	}
	elsif (uc($_[0]) eq 'AL')
	{
		$EAX = $EAX | 255;  #same with AL bits...
		$EAX = ($EAX & ($AL + 4294967040));
		$EAX %= 4294967295;
		&update32('EAX');
	}
	elsif (uc($_[0]) eq 'BH')
	{
		$EBX = $EBX | 65280;
		$EBX = $EBX & ($BH + 4294902015);  
		$EBX %= 4294967295;
		&update32('EBX');
	}
	elsif (uc($_[0]) eq 'BL')
	{
		$EBX = $EBX | 255;
		$EBX = $EBX & ($BL + 4294967040);
		$EBX %= 4294967295;
		&update32('EBX');
	}
	elsif (uc($_[0]) eq 'CH')
	{
		$ECX = $ECX | 65280;
		$ECX = $ECX & ($CH + 4294902015);  
		$ECX %= 4294967295;
		&update32('ECX');
	}
	elsif (uc($_[0]) eq 'CL')
	{
		$ECX = $ECX | 255;
		$ECX = $ECX & ($CL + 4294967040);
		$ECX %= 4294967295;
		&update32('ECX');
	}
	elsif (uc($_[0]) eq 'DH')
	{
		$EDX = $EDX | 65280;
		$EDX = $EDX & ($DH + 4294902015);  
		$EDX %= 4294967295;
		&update32('EDX');
	}
	elsif (uc($_[0]) eq 'DL')
	{
		$EDX = $EDX | 255;
		$EDX = $EDX & ($DL + 4294967040);
		$EDX %= 4294967295;
		&update32('EDX');
	}
	else
	{
		&tellme("Invalid update call with: \33[332m".$_[0]."!",4,0);
	}
}
sub updatestack #call updatestack('PUSH', val) or updatestack('POP','REG')
{
	my $dothis = $_[0];
	my $tothis = $_[1];

	if (uc($dothis) eq 'POP')
	{
	&tellme("\33[35m$dothis\33[33m being executed into\33[32m $tothis.",4,3);
	&tellme("Popped value is:\33[31m $STACK[0].",5,3);
		if (uc(substr($tothis, 0, 1)) ne 'E')  # if a non extended reg was chosen...
		{
			&tellme("Unaligned stack pop! Not executed!",4,0);
		}
		else # mov the value into the reg from the stack...
		{
			if (uc($tothis) eq 'EAX')
			{
				$EAX = &returnvalueof($STACK[0]);
				&update32('EAX');
			}
			elsif (uc($tothis) eq 'EBX')
			{
				$EBX = &returnvalueof($STACK[0]);
				&update32('EBX');

			}
			elsif (uc($tothis) eq 'ECX')
			{
				$ECX = &returnvalueof($STACK[0]);
				&update32('ECX');
			}
			elsif (uc($tothis) eq 'EDX')
			{
				$EDX = &returnvalueof($STACK[0]);
				&update32('EDX');
			}
			elsif (uc($tothis) eq 'ESP')
			{
				$ESP = &returnvalueof($STACK[0]);
			}
			elsif (uc($tothis) eq 'EDI')
			{
				$EDI = &returnvalueof($STACK[0]);
			}
			elsif (uc($tothis) eq 'EBP')
			{
				$EBP = &returnvalueof($STACK[0]);
			}
			else
			{
				&tellme("Invalid Register!",4,0);
			}
			shift(@STACK); # remove the first element even on register error. who knows...
			$OFFSET-- ;    # decrement out placeholding var to align the &status's and handlings...
			&tellme("\33[35m ".$tothis."\33[33m is now \33[32m ". &returnvalueof($tothis).".",3,3);
		}
	}
	elsif (uc($dothis) eq 'PUSH')
	{
		unshift(@STACK,&dectohex($tothis));  # push the value into the beginning of the stack array
		$OFFSET++ ; # incrememnt our place holding var.
		&tellme("\33[35m ".$tothis." \33[33m has been pushed to stack.",4,3);
	
	}
	else
	{
		&tellme("Invalid update call with: $dothis!",4,0);
	}
}
sub updateflags  #call it with (reg, optional value)
{
	my $tmpreg = $_[0];
	my $tmpregval = &returnvalueof($tmpreg);
	my $tmpval = 0 ;
	$tmpval = $_[1] if defined($_[1]);
	my $mysize =0;
	
	&tellme("Updating flags...",4,3);
	
	#deal with the zero flag
	if($tmpregval == 0)
	{
		$ZF = 1;
	}
	else
	{
		$ZF = 0;
	}
	
	#deal with the sign flag
	if($tmpregval < 0)
	{
		$SF = 1;
	}
	else
	{
		$SF = 0;
	}
	#set the size for the value to see if we overflowed...
	$mysize = &size($tmpreg);
	
	if(&returnvalueof($tmpval) > (2**$mysize))
	{
		$OF = 1;
	}
	else
	{
		$OF = 0;
	}
	&tellme("Flags are now changed. \33[34mZF: \33[36m$ZF  \33[34mSF: \33[36m$SF  \33[34mOF: \33[36m$OF ",4,3);
}
}
{ # Support subs...
sub status
{
	#Action: prints out the current state of all the vars. Formatted nicely.
	# all conditionals here are only for formatting.
	
	my ($teax, $tebx, $tecx, $tedx, $oddnum, $tmpoff);
	
	print color('red'),"\n Current status:\n", color('reset');
	print  color('bold blue'), "\n   All purpose Registers\n----------------------------\n", color('reset');
	$teax = sprintf("EAX: 0x%08X\tAX: 0x%04X\tAH: 0x%02X\tAL: 0x%02X\n", &returnvalueof('EAX',1),&returnvalueof('AX',1),&returnvalueof('AH',1),&returnvalueof('AL',1));
	$tebx = sprintf("EBX: 0x%08X\tBX: 0x%04X\tBH: 0x%02X\tBL: 0x%02X\n", &returnvalueof('EBX',1),&returnvalueof('BX',1),&returnvalueof('BH',1),&returnvalueof('BL',1));
	$tecx = sprintf("ECX: 0x%08X\tCX: 0x%04X\tCH: 0x%02X\tCL: 0x%02X\n", &returnvalueof('ECX',1),&returnvalueof('CX',1),&returnvalueof('CH',1),&returnvalueof('CL',1));
	$tedx = sprintf("EDX: 0x%08X\tDX: 0x%04X\tDH: 0x%02X\tDL: 0x%02X\n\n\n",&returnvalueof('EDX',1),&returnvalueof('DX',1),&returnvalueof('DH',1),&returnvalueof('DL',1));
	print color('green'), $teax, color('reset');
	print color('bold green'), $tebx, color('reset');
	print color('green'), $tecx, color('reset');
	print color('bold green'), $tedx, color('reset');
	print color('bold cyan'), "\tZF: ", color('yellow'), $ZF, color('bold cyan'), "  SF: ", color('yellow'), $SF, color('bold cyan'), "  OF: ", color('yellow'), $OF ,"\n", color('reset');
			
	printf  "\e[32m\n   ESP: 0x%08X\tEBP: 0x%08X\n\n\n",&returnvalueof('ESP',1), $EBP;
			
	
	$oddnum = 1;
	print 	color('bold blue'), "           Stack\n".
			"-----------------------------\n";
	print	"----Hex-----------Decimal---------String----\n", color('reset');
	
	$tmpoff = $OFFSET;
	foreach (@STACK)
	{
		#printf "0x%08X\t%d\t%s\n",&dectohex($_),$_,&dectostring($_);
		
		my $tstack = sprintf "0x%08X",&dectohex($_);
		if ($_ >= 0)
		{
			$tstack .= sprintf "\t %d", $_;
		}
		else
		{
			$tstack .= sprintf "\t%d", $_;
		}
		$tstack .= sprintf "\t%s",&dectostring($_);
			
		if (($oddnum % 2) == 0)
		{
			print color('green'), $tstack, color('reset');
		}
		else
		{
			print color('bold green'), $tstack, color('reset');
		}
		$oddnum++;
		
		if ($EAX == ($ESP + $tmpoff))
		{
			print color('bold red'),"\t <-- EAX", color('reset');
		}
		elsif ($EBX == ($ESP + $tmpoff))
		{
			print color('bold red'),"\t <-- EBX", color('reset');
		}
		elsif ($ECX == ($ESP + $tmpoff))
		{
			print color('bold red'),"\t <-- ECX", color('reset');
		}
		elsif ($EDX == ($ESP + $tmpoff))
		{
			print color('bold red'),"\t <-- EDX", color('reset');
		}
		$tmpoff --;
		print "\n";
	}
	
	print color('reset'), "\n\n";
	
}
sub tellme
{
	#debug output
	#Input: "str to say", how indented, how urgent(0-3), force quiet (used in status and returnvalueof)
	# urgent of 0 will force it to be said.
	return 0 if $verbose < $_[2] or defined($_[3]);
	if (($tellcount % 2) == 0)
	{
        print color('bold cyan'),"<>"."  "x$_[1]."{!} " . "--  ", color('yellow'), "$_[0]\n", color('reset');
	}
	else
	{
        print color('cyan'),"<>"."  "x$_[1]."{!} " . "--  ", color('bold yellow'), "$_[0]\n", color('reset');
	}
	$tellcount++;
}

sub trim 
{
	#remove whitespace from a string or array. taken from the intertubes, i dont know this code...
  @_ = $_ if not @_ and defined wantarray;
  @_ = @_ if defined wantarray;
  for (@_ ? @_ : $_) { s/^\s+//, s/\s+$// }
  return wantarray ? @_ : $_[0] if defined wantarray;
}
sub is_integer 
{
	#is this an integer?
   defined $_[0] && $_[0] =~ /^[+-]?\d+$/;
}
sub getnumericinput 
{
	# the getinput subs may be used for interactive mode...
	my $TMP;
	$TMP = <STDIN>;
	chomp($TMP);
	if (&is_integer($TMP) == 0) 
	{
		&tellme("Invalid Response!",1,0);
		exit;
	}
	return($TMP);
}
sub getinput
{
	my $TMP;
	$TMP = <STDIN>;
	chomp($TMP);
	return($TMP);
}

sub returnvalueof
{
	# accepts anything and checks to see if it is a var in the script. if it is, returns its value, if not, returns it the same.
	my $var;
	if (uc($_[0]) eq 'EAX')
	{
		$var = &dectohex($EAX);
	}
	elsif (uc($_[0]) eq 'EBX')
	{
		$var = &dectohex($EBX);
	}
	elsif (uc($_[0]) eq 'ECX')
	{
		$var = &dectohex($ECX);
	}
	elsif (uc($_[0]) eq 'EDX')
	{
		$var = &dectohex($EDX);
	}
	elsif (uc($_[0]) eq 'AX')
	{
		$var = &dectohex($AX);
	}
	elsif (uc($_[0]) eq 'BX')
	{
		$var = &dectohex($BX);
	}
	elsif (uc($_[0]) eq 'CX')
	{
		$var = &dectohex($CX);
	}
	elsif (uc($_[0]) eq 'DX')
	{
		$var = &dectohex($DX);
	}
	elsif (uc($_[0]) eq 'AL')
	{
		$var = &dectohex($AL);
	}
	elsif (uc($_[0]) eq 'AH')
	{
		#for formatting and actual processing, all higher order reg's are shifted to the right by 8 bits.
		$var = &dectohex($AH >> 8);
	}
	elsif (uc($_[0]) eq 'BL')
	{
		$var = &dectohex($BL);
	}
	elsif (uc($_[0]) eq 'BH')
	{
		$var = &dectohex($BH >> 8)
	}
	elsif (uc($_[0]) eq 'CL')
	{
		$var = &dectohex($CL);
	}
	elsif (uc($_[0]) eq 'CH')
	{
		$var = &dectohex($CH >> 8)
	}
	elsif (uc($_[0]) eq 'DL')
	{
		$var = &dectohex($DL);
	}
	elsif (uc($_[0]) eq 'DH')
	{
		$var = &dectohex($DH >> 8)
	}
	elsif (uc($_[0]) eq 'EBP')
	{
		$var = &dectohex($EBP);
	}
	elsif (uc($_[0]) eq 'ESP')
	{
		$var = (&dectohex($ESP) + $OFFSET);
	}
	elsif (uc($_[0]) eq 'ESI')
	{
		$var = &dectohex($ESI);
	}
	elsif (uc($_[0]) eq 'EDI')
	{
		$var = &dectohex($EDI);
	}
	else
	{
		if (substr($_[0],0,2) eq '0x')
		{
			$var = oct $_[0];
		}
		else 
		{
			$var = $_[0];
		}
	}
	&tellme("Returnvalueof \33[31m".$_[0]."\33[33m is:\e[35m $var.",5,2,1) if !defined($_[1]);
	return($var);
}

sub size
{
	my $tmp = $_[0];
	if(uc(substr($tmp,0,1)) eq 'E')
	{
		&tellme("Bit length of $tmp is: \33[31m 32",5,3);
		return(8*4);
	}
	elsif(uc(substr($tmp,-1,1)) eq 'X')
	{
		&tellme("Bit length of $tmp is: \33[31m 16",5,3);
		return(8*2);
	}
	elsif(uc(substr($tmp,-1,1)) eq 'H' or uc(substr($tmp,-1,1)) eq 'L')
	{
		&tellme("Bit length of $tmp is: \33[31m 8",5,3);
		return(8*1);
	}
	else
	{
		my $use = &returnvalueof($tmp);
		if($use < 256)
		{
			&tellme("Bit length of $tmp is: \33[31m 8",5,3);
			return(8*1);
		}
		elsif($use < 65536)
		{
			&tellme("Bit length of $tmp is: \33[31m 16",5,3);
			return(8*2);
		}
		elsif($use < 4294967296)
		{
			&tellme("Bit length of $tmp is: \33[31m 32",5,3);
			return(8*4);
		}
	}
}
}
{  # i need people's help on these subs, please!! feel free to rewrite the recursion i have if you feel its necesary.
sub numerictohex #reads in '41414141' and outputs 0x41414141
{
	my $temp = sprintf("%X",$_[0]);
	return($temp);
}
sub numerictostring  #reads in '41414141' and outputs 'AAAA'
{
	return(&hextostring(&numerictohex($_[0])));
}

sub int_to_hexstr # takes a integer and return the hex string
{
	my $int = $_[0];
	my $hex = sprintf("0x%X", $int);
	return $hex;
}

sub hextostring  #reads in 0x41414141 and outputs 'AAAA'
{
        my $hex = &int_to_hexstr($_[0]);
        $hex = substr($hex, 2);
        my $ascii = pack("H*", "$hex");
        return $ascii;
}
sub hextonumeric #reads in 0x41414141 and outputs '41414141'
{
	# not here obviously. not really needed either...
}

sub stringtohex  #reads in 'AAAA' and outputs 0x41414141
{
	my $TMP = $_[0];
	my $hex = unpack('H*', "$TMP");
	return($hex);
}

sub stringtonumeric #reads in 'AAAA' and outputs '41414141'
{
	return(&hextonumeric(&stringtohex($_[0])));
}

sub dectohex # reads in 65535 and outputs ffff
{
	my $TMP = $_[0];
	my $hex = unpack('A*', "$TMP");
	return($hex);
}

sub dectostring #reads in large number and outputs the correspond text. 1094795585 and outputs 'AAAA' 
{
	#shift right by 8 bits until all 32 bits have been processed
	#AND the $_[0] against 255 to get the first byte then
	# str .= chr() and return $str
	my ($STR, $TMP);
	$TMP = $_[0];
	$STR="";
	$STR .= chr(($TMP & 255));  # change into a char and concat onto a str.
	do
	{
		$TMP = $TMP >> 8;
		# if (($TMP & 255) == 10)
		# {
			# $STR .= '(cr)'
		# }
		# elsif (($TMP & 255) == 13)
		# {
			# $STR .= '(lf)'
		# }
		# else
		# {
			$STR .= chr(($TMP & 255));
		#}
	} while ($TMP > 255);

	return($STR);
}
}

{ #actual mode subs.
sub parsecmd
{
	my $LINE = $_[0];
	chomp($LINE); # get rid of that newline
		$LINE =~ s/(BYTE|DWORD|WORD)//i; # get rid of pesky words we dont care about now...
		$MATCH = 0;
		if ($LINE eq ";status")  #allow for forced status printings inside the asm file. useful for debugging.
		{
			&status;
		}
		if ($LINE eq ";status" or uc(substr($LINE,0,7)) eq 'BITS 32')  #allow for forced status printings inside the asm file. useful for debugging.
		{
			$LINE = '';
		}
		my $newline;
		$LINE =~ m/(^[^;]*)/; #split at comments
		$newline = $1;
		$newline =~ s/\[([a-zA-Z]+)\]/[$1+0]/; #replace all [{reg}] with [{reg} + 0} to parse...
		# i should have the blank and comment check in a sep if, but i want to keep it this way for seperators...
		if (substr(&trim($newline),0,1) ne ';' and &trim($newline) ne '' and ($newline =~ m/[[]/)) #if there is a "[" in the line
		{
			&DEREF($newline); # then it needs to be taken care of
		}
		elsif (substr(&trim($newline),0,1) ne ';' and &trim($newline) ne '')
		{
			my $INSTR = '';
			my $FIRSTOP = '';
			my $SECONDOP = '';;
			$newline =~  m/(\w+)[ \t]+(\w+)[ \t]*,?[ \t]*(([^;]*))/i;  #split that sucker up
				$INSTR = &trim(uc($1));
				$FIRSTOP = &trim($2) if ($INSTR ne 'CDQ' and defined($2));
				$SECONDOP = &trim($3) if($INSTR ne 'CDQ' and defined($3));
				&tellme("Instruction: >\33[31m$INSTR\33[33m<   FirstOp: >\33[31m$FIRSTOP\33[33m<   Value: >\33[31m$SECONDOP\33[33m<",3,2);
				#call the sub that is required and set match to 1
				#if its a label then ignore it...
				$MATCH = 1 if (substr($INSTR,-1,1) eq ":");
					if ($INSTR eq 'XOR') {
						&XOR($INSTR,uc($FIRSTOP),$SECONDOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'MOV')
					{
						&MOV($INSTR,uc($FIRSTOP),$SECONDOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'XCHG')
					{
						&XCHG($INSTR,uc($FIRSTOP),uc($SECONDOP));
						$MATCH=1;
					}
					elsif ($INSTR eq 'AND')
					{
						&AND($INSTR,uc($FIRSTOP),$SECONDOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'SUB')
					{
						&SUB($INSTR,uc($FIRSTOP),$SECONDOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'ADD')
					{
						&ADD($INSTR,uc($FIRSTOP),$SECONDOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'CMP')
					{
						&CMP($INSTR,uc($FIRSTOP),$SECONDOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'TEST')
					{
						&TEST($INSTR,uc($FIRSTOP),$SECONDOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'LEA')
					{
						&LEA($INSTR,uc($FIRSTOP),uc($SECONDOP));
						$MATCH=1;
					}
					elsif ($INSTR eq 'OR')
					{
						&OR($INSTR,uc($FIRSTOP),$SECONDOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'JNS' or $INSTR eq 'JS' or $INSTR eq 'JE' or $INSTR eq 'JNE' or $INSTR eq 'JZ' or $INSTR eq 'JNZ')
					{
						&JMP($INSTR,uc($FIRSTOP));
						$MATCH=1;
					}
					elsif ($INSTR eq 'LOOP')
					{
						&LOOP($INSTR, $FIRSTOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'CDQ')
					{
						&CDQ;
						$MATCH=1;
					}
					elsif ($INSTR eq 'PUSH') {
						if (uc($FIRSTOP) eq 'BYTE' or uc($FIRSTOP) eq 'WORD' or uc($FIRSTOP) eq 'DWORD')
						{
							&DOSTACK($INSTR,$SECONDOP);
						}
						else
						{
							&DOSTACK($INSTR,$FIRSTOP);
						}
						$MATCH=1;
					}
					elsif ($INSTR eq 'JMP') {
						&JMP($INSTR,$FIRSTOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'INT') {
						&INT($INSTR,$FIRSTOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'CALL') {
						&CALL($INSTR,$FIRSTOP);
						$MATCH=1;
					}
					elsif ($INSTR eq 'POP')
					{
						&DOSTACK($INSTR,uc($FIRSTOP));
						$MATCH=1;
					}
					elsif ($INSTR eq 'INC') {
						&INC($INSTR,uc($FIRSTOP));
						$MATCH=1;
					}
					elsif ($INSTR eq 'DEC')
					{
						&DEC($INSTR,uc($FIRSTOP));
						$MATCH=1;
					}
					else # maybe a special was found? (not currently used...)
					{
						foreach my $OPERATOR (@SPECIAL)
						{
							if ($LINE =~ m/^\s*(\Q$OPERATOR\E)/i)
							{
								$MATCH = 1;
								&tellme("Special found!.",3,1);
								&SPECIAL($LINE);
							};
						};
					}
				if ($MATCH == 0) {
					&tellme("No match found for >>$LINE<<.",4,0);
				}
		}
}
sub createframe
{
	#this section grabs the file and reads it.
	my @tmpASM;
	my $placeholder = 0;
	my $linesplit = '';
	open($FILE, $_[0]) or die("{!!} - Could not read ASM file!\n");
	&tellme("Reading from $createfrm was a success.\n",1,0);
	@tmpASM= <$FILE>;
	close($FILE);
	&tellme("Starting to parse the ASM code.",1,1);

	foreach my $cLINE (@tmpASM) 
	{
		$linesplit = '';    #clear the tmp var
		$cLINE  =~ m/(^[^;]*)/; # split at comments
		$linesplit = &trim($1) if (defined($1) and $1 ne '' and substr(&trim($1),0,1) ne ';');  # if we got something...
		push(@LINES,$linesplit);  #add it to our main parsing array
		$LINENUMBER{$linesplit} = $placeholder;  # add each line as a key with the number as a value.
		$placeholder ++;  # increment that number.
	};
	push(@LINES, 'NULL!');   #push a CODE ENDED line flag to the array
	&tellme("The ASM is $#LINES lines long.",2,2);
	print "\n";
	do
	{
		&parsecmd($LINES[$currentline]);
		$currentline++;
	} until ($LINES[$currentline] eq 'NULL!');
}
sub interactive
{
	my $iLINE= '';
	&tellme("\e[31mInteractive mode is enabled.",1,0);
	&tellme("\e[31mType your commands as you were were putting them into a file.",1,0);
	&tellme("\e[31mType ;status to check status, and int 0x80 to save a frame.",1,0);
	&tellme("\e[31mType -v or +v at any time to raise or lower the verbosity level.",1,0);
	&tellme("\e[31mType q or quit to leave.",2,0);
	print "\n";
	do 
	{
		&parsecmd($iLINE);
		print "\e[37mPhant0m>";
		$iLINE = &getinput;
		if ($iLINE eq '+V' or $iLINE eq '+v')
		{
			$verbose++ ;
			&tellme("\e[31mVerbosity increased.",2,0);
			$iLINE = '';
		}
		elsif ($iLINE eq '-V' or $iLINE eq '-v')
		{
			$verbose-- ;
			$verbose =0 if $verbose == -1;
			&tellme("\e[31mVerbosity decreased.",2,0);
			$iLINE = '';
		}
	} until (uc($iLINE) eq 'QUIT'  or uc($iLINE) eq 'Q' or uc($iLINE) eq 'E' or uc($iLINE) eq 'EXIT');
}
sub getframe
{
	#Maybe change this into an ASM shell, and send to parse?... seems easier and better for the guy that way...
	&tellme("What is EAX? Decimal values only. Just convert all your hex values to decimal. To set EAX to ESP use the value 3735928544.\n",3,0);
	$EAX=&getnumericinput;
	&tellme("What is EBX? Decimal values only. Just convert all your hex values to decimal. To set EBX to ESP use the value 3735928544.\n",3,0);
	$EBX=&getnumericinput;
	&tellme("What is ECX? Decimal values only. Just convert all your hex values to decimal. To set ECX to ESP use the value 3735928544.\n",3,0);
	$ECX=&getnumericinput;
	&tellme("What is EDX? Decimal values only. Just convert all your hex values to decimal. To set EDX to ESP use the value 3735928544.\n",3,0);
	$EDX=&getnumericinput;
	&update32('EAX');
	&update32('EDX');
	&update32('ECX');
	&update32('EBX');
	#set up loop to read into stack...
	&tellme("Begin typing in your stack frame in pushing (LIFO) order, 4 bytes at a time, proceded by 0x.\n\tExamples: 0x1F2374e5 0xddEf1101\n\tThis does not check for valid characters though, so don't screw up.\n\tTo push a register location to the stack type lREG like lEAX.\n\tTo push ESP to the stack use the value 0xDEADBEEF.\n\t\tAnd type q to leave the loop.",3,0);
	my $obj = <STDIN>;
	chomp($obj);
	if (lc($obj) ne 'q')
	{
		do 
		{
			&updatestack('PUSH',&returnvalueof($obj));
			$obj = <STDIN>;
			chomp($obj);
		} until (lc($obj) eq 'q');
	}
	&tellme("Stack set up.",3,0);
	&status;
}
sub saveframe
{
	my $framefile = $FRAMECOUNT.'.frm';  # name the framefile in an ordinal fashion
	my $directory = "frames";
	my $subdir = basename($createfrm);
	my $fh;
	my $lastcmd = $_[0];
	&tellme("Frame save triggered.",5,0);
	&status;
	&tellme("Saving frame $FRAMECOUNT!", 5,0);
	
	#create the directory tree to keep things organized.
	unless(-e $directory or mkdir $directory)
	{
		die "{!!} - Unable to create $directory directory!\n";
	}
	chdir($directory) or die "{!!} - Unable to directories!\n";
	unless(-e $subdir or mkdir $subdir)
	{
		die "{!!} - Unable to create $createfrm directory!\n";
	}
	chdir("../");
	open $fh, ">", $directory.'/'.$subdir.'/'.$framefile or die("{!!} - Could not write to $_[0]!\n");
	
	#print out our vars
	print $fh $lastcmd."\n";
	print $fh $EAX."\n";
	print $fh $EBX."\n";
	print $fh $ECX."\n";
	print $fh $EDX."\n";
	print $fh $EBP."\n";
	print $fh $EDI."\n";
	print $fh $ESI."\n";
	
	#reverse the stack and print to file.
	my @tmpSTACK = reverse(@STACK);
	foreach (@tmpSTACK)  #backwards
	{
		print $fh $_."\n";
	}
	close $fh;
	$FRAMECOUNT ++;
}
sub readframe
{
	my (@FRAME, $framefile);
	open($framefile, "$_[0]") or die("{!!} - Could not read $_[0]!\n");
	&tellme("Reading from $_[0] was a success.\n",2,1);
	@FRAME= <$framefile>;
	close($framefile);
	&tellme("Starting to parse the FRAME.",3,1);
	
	#read in our vars...
	$LASTCMD = $FRAME[0];
	shift(@FRAME);
	&tellme("Frame saved because of $LASTCMD.", 3,1);
	$EAX = $FRAME[0];
	shift(@FRAME);
	$EBX = $FRAME[0];
	shift(@FRAME);
	$ECX = $FRAME[0];
	shift(@FRAME);
	$EDX = $FRAME[0];
	shift(@FRAME);
	$EBP = $FRAME[0];
	shift(@FRAME);
	$EDI = $FRAME[0];
	shift(@FRAME);
	$ESI = $FRAME[0];
	shift(@FRAME);
	&update32('EAX');
	&update32('EBX');
	&update32('ECX');
	&update32('EDX');
	foreach (@FRAME)
	{
		&DOSTACK('PUSH',&returnvalueof($_));
	}
	if (uc($LASTCMD) eq 'INT 0x80' and $EAX = 102) # account for the syscall if necessary...
	{
		&tellme("SYSCALL returns a file descripter into EAX.",4,1);
		$EAX = $fd;
		&update32('EAX');
	}
}
sub generateASM
{
	&tellme("\e[31mFrame-based ASM generation is not yet implemented!",2,0);
	exit(1);
	my $dh;
	opendir($dh, 'frames') || die("{!!} - Could not open frames directory!\n");
	&tellme("Entered Obfuscation sub with $FRAMECOUNT frames.",4,1);
	&tellme("Beginning to read frames!",1,1);	
	while(readdir $dh)
	{
		&readframe("frames/$_");
		&status;
	}
	close($dh);
}
sub linebyline
{
	&tellme("\e[31mLine-by-Line obfuscation is not yet implemented!",2,0);
	exit(1);
}
}
sub Usage
{
	print color('bold red'),$banner . "\n\n", color('reset');
	&tellme("\e[31m$_[0]",1,0);
	&tellme("Usage: \e[35m$0 \e[32m-|--{mode} \e[34m{file} \e[36m-v|--verbose (one for each level of verbosity.)",2,0);
	print"\n";
			&tellme("Modes:",2,0);
			&tellme("------------------------------------------------------------------",1,0);
			&tellme("i|interactive    Manually create a frame file from a ASM shell.",2,0);
			print"\n";
			&tellme("r|readframe      Read from a previously created frame file.",2,0);
			print"\n";
			&tellme("g|generatecode   Generate ASM from a created frame file",2,0);
			print"\n";
			&tellme("c|createframe    Create a frame file from an ASM file.",2,0);
			print"\n";
			&tellme("l|linebyline     Do line-by Line obfuscation from an ASM file.",2,0);
			&tellme("                 creating frame files along the way.",2,0);
	exit(1);
}