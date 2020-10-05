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

package Foswiki::Plugins::MarkdownPlugin;

use strict;
use warnings;

use Foswiki::Func ();

our $VERSION = '2.00';
our $RELEASE = '05 Oct 2020';
our $SHORTDESCRIPTION = 'Markdown support for Foswiki';
our $NO_PREFS_IN_TOPIC = 1;
our $core;

sub initPlugin {

  Foswiki::Func::registerTagHandler('MARKDOWN', sub { return getCore()->MARKDOWN(@_); });

  return 1;
}

sub beforeCommonTagsHandler {
  my ($text) = @_;

  return unless $text =~/(?:START|BEGIN|STOP|END)MARKDOWN/;

  my $verbatim = {};
  $text = Foswiki::takeOutBlocks($text, 'verbatim', $verbatim); # SMELL: we have to do this _again_ by _ourselves as any other callback doesn't cut it
  $text =~ s/%(?:START|BEGIN)MARKDOWN(?:\{(.*?)\})?%(.*?)%(?:STOP|END)MARKDOWN%/getCore()->handleMarkdownArea($_[2], $_[1], $2, $1)/ges;
  Foswiki::putBackBlocks(\$text, $verbatim, 'verbatim');

  $_[0] = $text;
}

sub getCore {
  unless (defined $core) {
    require Foswiki::Plugins::MarkdownPlugin::Core;
    $core = Foswiki::Plugins::MarkdownPlugin::Core->new();
  }
  return $core;
}

sub finishPlugin {
  if (defined $core) {
    $core->finish;
    undef $core;
  }
}

1;
