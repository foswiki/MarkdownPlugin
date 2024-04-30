# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
#
# MarkdownPlugin is Copyright (C) 2023-2024 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::MarkdownPlugin::TextMarkup;

use strict;
use warnings;

use Text::Markup ();
use Foswiki::Sandbox ();
use File::Temp ();
use Encode ();

use Foswiki::Plugins::MarkdownPlugin::Converter ();
our @ISA = ('Foswiki::Plugins::MarkdownPlugin::Converter');

sub process {
  my ($this, $text, $params) = @_;

  my $fileName;
  my $tmpFile;

  if (defined($text)) {
    #$text = Encode::encode_utf8($text);
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    $tmpFile = File::Temp->new();
    print $tmpFile $text;
    $fileName = $tmpFile->filename;
  } else {
    if (defined($params->{attachment})) {
      my $web = $params->{web};
      $web =~ s/\./\//g;

      $fileName = $Foswiki::cfg{PubDir} . '/' . $web . '/' . $params->{topic} . '/' . $params->{attachment};
      $fileName = Foswiki::Sandbox::normalizeFileName($fileName);
    }
  }

  return "ERROR: no text found" unless defined $fileName;

  my $format = $params->{format} || $Foswiki::cfg{MarkdownPlugin}{PandocFormat} || "markdown";
  return "ERROR: unknown format" unless $this->isKnownFormat($format);

  #print STDERR "file=$fileName\n";
  return "ERROR: file not found" unless -e $fileName;

  my $output = $this->getParser->parse(
    file => $fileName,
    format => $format,
    options => [
      raw => 1
    ]
  ) // 'undef';

  #print STDERR "output=$output\n";

  return $output;
  #return Encode::decode_utf8($output);
}

sub getParser {
  my $this = shift;

  unless (defined $this->{_parser}) {
    $this->{_parser} = Text::Markup->new(
      default_format   => $Foswiki::cfg{MarkdownPlugin}{PandocFormat} || "markdown",
      default_encoding => 'UTF-8',
    );
  }

  return $this->{_parser};
}

sub isKnownFormat {
  my ($this, $format) = @_;

  return $this->formats->{$format};
}


sub formats {
  my $this = shift;

  unless ($this->{_formats}) {
    $this->{_formats} = ();
    $this->{_formats}{$_} = 1 foreach Text::Markup->formats();
  }

  return $this->{_formats};
}

sub finish {
  my $this = shift;

  undef $this->{_parser};
}

1;

