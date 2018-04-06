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

package Foswiki::Plugins::MarkdownPlugin::Core;

use strict;
use warnings;
use Foswiki::Func ();

use constant TRACE => 0; # toggle me

sub _writeDebug {
  return unless TRACE;
  #Foswiki::Func::writeDebug("MarkdownPlugin::Core - $_[0]");
  print STDERR "MarkdownPlugin::Core - $_[0]\n";
}

sub new {
  my $class = shift;

  my $this = bless({
    converterImpl => $Foswiki::cfg{MarkdownPlugin}{Converter} || 'Pandoc',
    @_
  }, $class);

  return $this;
}

sub finish {
  my $this = shift;

  if ($this->{_converter}) {
    $this->{_converter}->finish;
  }
  undef $this->{_converter};
}

sub converter {
  my $this = shift;

  unless (defined $this->{_converter}) {
    my $impl = $this->{converterImpl};
    $impl =~ s/://g;
    $impl = "Foswiki::Plugins::MarkdownPlugin::$impl";
    _writeDebug("impl=$impl");
    eval "require $impl";
    die "Cannot load converter implementation: $@" if $@;

    $this->{_converter} = $impl->new();
  }

  return $this->{_converter};
}

sub MARKDOWN {
  my ($this, $session, $params, $topic, $web) = @_;

  _writeDebug("called MARKDOWN()");
  my $text;

  if (defined $params->{_DEFAULT} || $params->{text}) {
    $text = $params->{_DEFAULT} || $params->{text};
  } elsif (defined $params->{section} || defined $params->{topic}) {
    my ($thisWeb, $thisTopic) = Foswiki::Func::normalizeWebTopicName($web, $params->{topic} || $topic);

    $text = '%INCLUDE{"' . $thisWeb . '.' . $thisTopic . '"';
    $text .= ' section="' . $params->{section} . '"' if defined $params->{section};
    $text .= ' rev="' . $params->{rev} . '"' if defined $params->{rev};
    $text .= ' warn="off"}%';

    $text = Foswiki::Func::expandCommonVariables($text, $topic, $web);
  } elsif (defined $params->{attachment}) {
    my ($thisWeb, $thisTopic) = Foswiki::Func::normalizeWebTopicName($web, $params->{topic} || $topic);
    $text = Foswiki::Func::readAttachment($thisWeb, $thisTopic, $params->{attachment}, $params->{rev});
  }
 
  return $this->convert($text, $params);
}

sub handleMarkdownArea {
  my ($this, $web, $topic, $text, $args) = @_;

  my %params = Foswiki::Func::extractParameters($args || "");

  return $this->convert($text, \%params);
}

sub addCss {
  my ($this) = @_;

  return if $this->{_doneCss};
  $this->{_doneCss} = 1;
  Foswiki::Func::addToZone('head', 'MARKDOWN', '<link rel="stylesheet" type="text/css" href="%PUBURLPATH%/%SYSTEMWEB%/MarkdownPlugin/styles.css" media="all" />');
}

sub convert {
  my ($this, $text, $params) = @_;

  _writeDebug("text=$text");
  my $html = $this->converter->process($text, $params); 

  $this->addCss();

  _writeDebug("html=$html");
  return "<div class='markdownBody'><literal>$html</literal></div>";
} 

1;
