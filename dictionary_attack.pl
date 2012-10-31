#!/usr/bin/perl

#print "Hash: ";
#$temp = crypt "9field1", "BE";
#print $temp;

$passwordFile = $ARGV[0];
$dictionaryFile = $ARGV[1];

my @special_characters = split(//, "0123456789%#&!");

my $PASSWORD_FILE;
my $DICTIONARY_FILE;

my %rainbow;

open($PASSWORD_FILE, "<$passwordFile") or die "Could not open file <$passwordFile>";
open($DICTIONARY_FILE, "<$dictionaryFile") or die "Could not open file <$dictionaryFile>";

my %variations;
&generateVariations($DICTIONARY_FILE);

close $DICTIONARY_FILE;

while(<$PASSWORD_FILE>){
	next if ($_ =~ /^\s*$/);
	&crack($_);
}

close $PASSWORD_FILE;


sub crack { # pass line of passwd file
	my $line = @_[0];

	#print $line;

	my $user, $passwdHash, $salt;
	($user, $passwdHash) = split(':', $line);
	
	$salt = substr $passwdHash, 0, 2;

	if (!$VAR{$salt}{COMPLETE} == 1) {
		foreach my $plaintext ( keys %variations ){
			#print $plaintext; # uncomment to see all variations
			my $temp_hash = crypt $plaintext, $salt;
			#print $temp_hash . " : " . $plaintext;
			$rainbow{$salt}{HASH}{$temp_hash} = $plaintext;
		}
		$rainbow{$salt}{COMPLETE} = 1;
	}

	if ($rainbow{$salt}{HASH}{$passwdHash}){
		print $user . ":" . $rainbow{$salt}{HASH}{$passwdHash};
	} else {
		#print STDERR "Password not found for " . $user . "\n";
	}

}

sub generateVariations { # takes open file handle (of dictionary)
	my $FH = @_[0];
	while(<$FH>){
		my $line = $_;
		next if ($line =~ /^\s*$/);
		$variations{$line} = 1;
		for ($count = 0; $count < length($line); $count++){
			for ($count2 = 0; $count2 < $#special_characters + 1; $count2++){
				$temp = $line;
				$char1 = @special_characters[$count2];
				substr($temp, $count, 0) = $char1;
				$variations{$temp} = 1;
				for ($count3 = 0; $count3 < length($temp); $count3++){
					for ($count4 = 0; $count4 < $#special_characters + 1; $count4++){
						$temp2 = $temp;
						$char2 = @special_characters[$count4];
						substr($temp2, $count3, 0) = $char2;
						$variations{$temp2} = 1;
					}
				}
			}
		}
	}
}

