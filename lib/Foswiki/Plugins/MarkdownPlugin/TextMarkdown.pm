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

package Foswiki::Plugins::MarkdownPlugin::TextMarkdown;

use strict;
use warnings;
use Text::Markdown qw(markdown);

use Foswiki::Plugins::MarkdownPlugin::Converter ();
our @ISA = ('Foswiki::Plugins::MarkdownPlugin::Converter');

sub process {
  my ($this, $text, $params) = @_;

  $text = $this->readAttachment($params) unless defined $text;

  return markdown($text);
}

1;
