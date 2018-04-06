# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
#
# MarkdownPlugin is Copyright (C) 2018 Michael Daum http://michaeldaumconsulting.com
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

use Foswiki::Plugins::MarkdownPlugin::Converter ();
our @ISA = ('Foswiki::Plugins::MarkdownPlugin::Converter');

sub process {
  my ($this, $text, $params) = @_;

  my $tmpFile = File::Temp->new(SUFFIX => ".md");
  binmode($tmpFile, ":utf8");
  print $tmpFile $text;

  my $format = $params->{format} || "";
  $format = "markdown"
    unless $format =~ /^(docbook|haddock|json|latex|markdown|markdown_github|markdown_mmd|markdown_phpextra|markdown_strict|mediawiki|native|opml|rst|textile)$/;

  my $cmd = $Foswiki::cfg{MarkdownPlugin}{pandocCmd} || 'pandoc --ascii -f %FORMAT|S% -t html5 %FILENAME|F%';
  my ($output, $exit, $error) = Foswiki::Sandbox->sysCommand(
    $cmd,
    FORMAT => $format,
    FILENAME => $tmpFile->filename
  );

  return "ERROR: pandoc returned with code $exit - $error\n" if $exit;

  return $output;
}

1;
