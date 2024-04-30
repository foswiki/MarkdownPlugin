# ---+ Extensions
# ---++ MarkdownPlugin
# This is the configuration used by the <b>MarkdownPlugin</b>.

# **SELECT Pandoc,Parse::BBCode,Text::MultiMarkdown,Text::Markdown,Text::Markup,Text::Markdown::Hoedown,Text::Textile**
$Foswiki::cfg{MarkdownPlugin}{Converter} = 'Text::Markdown';

# **COMMAND CHECK='undefok' DISPLAY_IF="{MarkdownPlugin}{Converter}=='Pandoc'"**
# Path to the pandoc command 
$Foswiki::cfg{MarkdownPlugin}{PandocCmd} = 'pandoc -f %FORMAT|S% -t html5 %FILENAME|F%';

# **TEXT CHECK='undefok' DISPLAY_IF="{MarkdownPlugin}{Converter}=='Pandoc'"**
# Pandoc default input format. Note that you can choose different formats using the "format" parameter 
# of the %MARKDOWN macro.
$Foswiki::cfg{MarkdownPlugin}{PandocFormat} = 'markdown';

1;
