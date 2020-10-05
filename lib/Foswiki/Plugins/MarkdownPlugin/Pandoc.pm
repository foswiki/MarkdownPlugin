# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
#
# MarkdownPlugin is Copyright (C) 2018-2020 Michael Daum http://michaeldaumconsulting.com
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

package Foswiki::Plugins::MarkdownPlugin::Pandoc;

use strict;
use warnings;
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
    $text = Encode::encode_utf8($text);
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
  my $cmd = $Foswiki::cfg{MarkdownPlugin}{PandocCmd} || $Foswiki::cfg{MarkdownPlugin}{pandocCmd} || 'pandoc -f %FORMAT|S% -t html5 %FILENAME|F%';

  my ($output, $exit, $error) = Foswiki::Sandbox->sysCommand(
    $cmd,
    FORMAT => $format,
    FILENAME => $fileName
  );

  return "ERROR: pandoc returned with code $exit - $error\n" if $exit;

  return Encode::decode_utf8($output);
}

1;
