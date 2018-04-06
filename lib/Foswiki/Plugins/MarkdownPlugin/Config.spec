# ---+ Extensions
# ---++ MarkdownPlugin
# This is the configuration used by the <b>MarkdownPlugin</b>.

# **SELECT Pandoc,Text::Markdown,Text::MultiMarkdown,Text::Markdown::Hoedown,Text::Textile**
$Foswiki::cfg{MarkdownPlugin}{Converter} = 'Text::Markdown';

# **COMMAND CHECK='undefok' DISPLAY_IF="{MarkdownPlugin}{Converter}=='Pandoc'**
# Path to the pandoc command 
$Foswiki::cfg{MarkdownPlugin}{pandocCmd} = 'pandoc --ascii -f %FORMAT|S% -t html5 %FILENAME|F%';

1;
