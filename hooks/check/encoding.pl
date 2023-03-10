#!/usr/bin/env perl

# Git pre-commit hook script to verify text encoding and newline characters.
# Copyright (c) 2012 Takeshi Yaegashi.
# Copyright (c) 2023 Nautilus-YWL.
# License: MIT

# Works with Perl 5.8.  The bundled perl in msysgit is also supported.

# The script uses Encode module to support various text encodings.
# See http://search.cpan.org/perldoc?Encode::Supported for details.
# They can be followed by the following suffixes:
#   UTF-8 with BOM: -with-signature
#   Newline characters: -dos or -mac or -unix
# You can specify multiple encoding specifications separated by commas.
# Examples:
#   ascii,utf8 (any newline characters allowed)
#   ascii-unix,utf8-unix (only LF is allowed)
#   ascii-dos,utf-8-with-signature-dos (only CRLF is allowed)
#   utf-16,utf-16-be,utf-16-le

# Default encodings allowed to be committed, comma separated.
my $default_allowed = "ascii-unix,utf8-unix";

use strict;
use warnings;
use Encode;
use Encode::Guess qw/ascii utf8/;

$default_allowed = shift @ARGV if @ARGV > 0;

sub canonical_allowed {
        local $_ = shift;
        my @args = split /,/;
        my @ca = ();
        for (@args) {
                /(.*?)(-with-signature)?(-dos|-mac|-unix)?$/;
                my $e = $1;
                my $s = $2 || "";
                my $n = $3 || "";
                my $encoder = find_encoding($e);
                die "Unknown encoding: $e\n" unless ref $encoder;
                my $c = $encoder->name;
                # Fix blacklisted canonical encodings.
                $c =~ s/utf8-strict/utf8/;
                my @a = ("-unknown");
                push @a, $n ? $n : ("-dos", "-unix", "-mac");
                push @ca, $c.$s.$_ for @a;
        }
        return @ca;
}

my $failed = 0;

open my $files, "git diff --cached --name-only --diff-filter=ACM |git check-attr --stdin encoding |";

while (<$files>) {
        chomp;
        (my $file, my $attr, my $info) = split /: /;
        next if $info eq "unspecified" || $info eq "unset";
        my $allowed = $info eq "set" ? $default_allowed : $info;
        my $fh;
        unless (open $fh, "-|", "git", "show", ":./".$file) {
                print "$file: $!\n";
                $failed++;
                next;
        }
        binmode $fh;
        my $data = do { local $/; <$fh> };
        close $fh;
        unless ($? == 0) {
                print "$file: Sub process failed.\n";
                $failed++;
                next;
        }
        next unless length($data) > 0;
        my $decoder = Encode::Guess->guess($data);
        my $encoding;
        if (ref $decoder) {
                $encoding = $decoder->name;
                my $utf8 = $decoder->decode($data);
                if ($encoding eq "utf8" && $utf8 =~ /^\x{feff}/) {
                        $encoding .= "-with-signature";
                }
                if    ($utf8 =~ /\r\n/ms) { $encoding .= "-dos"; }
                elsif ($utf8 =~ /\r/ms)   { $encoding .= "-mac"; }
                elsif ($utf8 =~ /\n/ms)   { $encoding .= "-unix"; }
                else                      { $encoding .= "-unknown"; }
        }
        else {
                $encoding = $decoder;
        }
        unless (grep { $encoding eq $_ } canonical_allowed($allowed)) {
                print "$file: $encoding ($allowed)\n";
                $failed++;
        }
}

close $files;

if ($failed > 0) {
        exit 1;
}
