% -------------------------------------------------------------------
%  @LaTeX-class-file{
%     filename        = "ucl-thesis.cls",
%     version         = "0.5",
%     date            = "27 September 2014",
%     codetable       = "ISO/ASCII",
%     keywords        = "LaTeX, ucl-thesis, harvard-thesis",
%     supported       = "send email to pim.messelink.10@ucl.ac.uk or root@finlaymagui.re",
%     docstring       = "A thesis class for a UCL dissertation."
% --------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ucl-thesis}[2015/01/07 v0.5 University College London Thesis Class]
\LoadClass[12pt, oneside, a4paper]{book}
%book}

% Figures & Tables
\RequirePackage{graphicx}
\RequirePackage{nomencl}
\RequirePackage[closeFloats, noSeparatorLine]{fltpage} 
\RequirePackage{subcaption}
\RequirePackage{multirow}
\RequirePackage{booktabs} % for much better looking tables
\RequirePackage{longtable}
\RequirePackage[labelfont={sf,bf,small},textfont={sf,small},justification=RaggedRight,margin=0pt, figurewithin=section, tablewithin=section]{caption}
\RequirePackage{float}
\RequirePackage{pdfpages}

% Maths
\RequirePackage[centertags]{amsmath}
\RequirePackage{amssymb}
\RequirePackage{gensymb}
\RequirePackage{mathspec}
\RequirePackage{isomath}


% Fasta
\RequirePackage{filecontents}
\RequirePackage{listings}


%Physics
\RequirePackage{siunitx}

% Typesetting
\RequirePackage{url}
\RequirePackage{hyperref}
\RequirePackage{cleveref}
\hypersetup{
	linktocpage,
    colorlinks,
    citecolor=NavyBlue,
    filecolor=black,
    linkcolor=black,
    urlcolor=NavyBlue,
}
\RequirePackage[small, md, sc]{titlesec}
\RequirePackage{verbatim}
\RequirePackage[titles]{tocloft}
\setcounter{tocdepth}{3}
\setcounter{secnumdepth}{3}
\renewcommand{\cftchapfont}{\normalsize \scshape}
\RequirePackage{rotating}
\RequirePackage{lscape}
\RequirePackage{lettrine}
\RequirePackage[headheight=15pt, margin=20mm, bindingoffset=20mm, a4paper]{geometry}
\RequirePackage{fancyhdr} 
\pagestyle{plain} % options: empty , plain , fancy
\RequirePackage[helvetica]{quotchap}
\RequirePackage{titling}
\RequirePackage{setspace}

\doublespacing

% Font\documentclass{a4}
\RequirePackage{microtype}
\RequirePackage[LY1,T1,EU1]{fontenc}
\RequirePackage{fontspec,xltxtra,xunicode}
\defaultfontfeatures{Mapping=tex-text, Numbers=OldStyle}
\setromanfont[Mapping=tex-text, 
			  Numbers=OldStyle, 
			  Ligatures={Common}, 
			  SizeFeatures={%
		          {Size={-10}, Font=* Caption},
		          {Size={10-13.0}, Font=*},
		          {Size={13.01-19.9}, Font=* Subhead, Ligatures=Rare, Contextuals={Swash,Alternate}},
		       {Size={19.91-},Font=* Display, Ligatures=Rare, Contextuals={Swash,Alternate}}}]
			  {Arno Pro}  
\setmathsfont(Digits,Latin,Greek)[Numbers={OldStyle,Proportional}]{Arno Pro} 
\setmathrm{Arno Pro}

% Colors
\RequirePackage{color}
\definecolor{NavyBlue}{rgb}{0.0627, 0.2510, 0.4627}
\definecolor{chaptergrey}{rgb}{0.0627, 0.2510, 0.4627}

% Bibliography
\RequirePackage{natbib}
%[numbers, comma, sort&compress]{natbib}      

% Misc
\RequirePackage{pdfsync}
\synctex=1
\RequirePackage{afterpage} 
\RequirePackage{calc}
\RequirePackage[toc,page]{appendix}

% Definitions
\def\degreeyear#1{\gdef\@degreeyear{#1}}
\def\degreemonth#1{\gdef\@degreemonth{#1}}
\def\degreename#1{\gdef\@degreename{#1}}
\def\advisor#1{\gdef\@advisor{#1}}
\def\field#1{\gdef\@field{#1}}
\def\university#1{\gdef\@university{#1}}
\def\universitycity#1{\gdef\@universitycity{#1}}
\def\universitycountry#1{\gdef\@universitycountry{#1}}

% Title page
\renewcommand{\maketitle}{ 
	\singlespacing
	\thispagestyle{empty}
	\vspace*{\fill} \vspace{150pt} \begin{center}
	\Huge \textcolor{NavyBlue}{\thetitle} \normalsize \\ \vspace{100pt}
    \textsc{a dissertation presented \\ by\\
	\theauthor\\ 
	\vspace{12pt}
	in partial fulfillment of the requirements\\ 
	for the degree of\\ \@degreename\\ 
	\vspace*{\fill}
    %\includegraphics{front_material/NavyBlueu.pdf}\\
	\vspace{12pt}
	\@university\\ \@universitycity, \@universitycountry\\ 
    \@degreemonth\ \@degreeyear}
	\end{center}
}

% Copyright page
\newcommand{\copyrightpage}{
	\newpage \thispagestyle{empty} \vspace*{\fill}
    \textsc{ \noindent I, \theauthor, confirm that the work presented in this thesis is my own. Where information has been derived from other sources, I confirm that this has been indicated in the thesis.} \\ \vspace*{\fill}
    \textsc{ \noindent \copyright~\textit{\@degreeyear \hspace{3pt}~- \theauthor}} \\
	\noindent All rights reserved.
	\vspace*{\fill} \newpage 
}

% You might also consider licensing your work under Creative Commons). See: http://creativecommons.org/weblog/entry/12824 for other PhD students who have released their work under creative commons.

% Abstract page
\newcommand{\abstractpage}{
	\newpage
	\pagestyle{fancy}
	\lhead{Thesis advisors: \@advisor} \rhead{\@author}
	\renewcommand{\headrulewidth}{0.0pt} 
	\begin{center}
	\vspace*{1pt}
	\Large \textcolor{NavyBlue}{\textit{\@title}} \normalsize\\
	\vspace*{15pt}
    \textsc{Abstract} \\ 
	\end{center}
	\input{front_material/abstract}
	\newpage \lhead{} \rhead{}
	\cfoot{\thepage}
}

% Dedication page
\newcommand{\dedicationpage}{
	\pagestyle{fancy}
	\newpage \thispagestyle{fancy} \vspace*{\fill}
    \textsc{ \noindent \input{front_material/dedication}}
	\vspace*{\fill} \newpage 
}

% Acknowledgments page
\newcommand{\acknowledgements}{
	\chapter*{Acknowledgements}
	\noindent
	\input{front_material/thanks}
	\vspace*{\fill} 
	\newpage
}

\newcommand{\nomenpage}{
    \noindent \input{front_material/abbreviations}
	\vspace*{\fill} 
	\newpage
}

% maths page
\newcommand{\mathsnot}{
    \chapter*{Maths Notation}
	\noindent
	\input{front_material/maths_notation}
	\vspace*{\fill} 
	\newpage
}


%authorlist page
\newcommand{\authorlist}{
    \pagestyle{fancy}
    \newpage
    \thispagestyle{fancy}
    \chapter*{Author List}
    \noindent \input{front_material/authorlist}
    \newpage 
}


%authorlist page
\newcommand{\publications}{
    \pagestyle{fancy}
    \newpage
    \thispagestyle{fancy}
    \chapter*{Publications}
    \noindent \input{front_material/publications}
    \newpage 
}

%% An environment for paragraph-style section
%\providecommand\newthought[1]{
%   \addvspace{1.0\baselineskip plus 0.5ex minus 0.2ex}%
%   \noindent\textsc{#1}
%}
% SI commands
\sisetup{range-phrase=-}
\sisetup{range-units=single}
\DeclareSIUnit\bp{bp}
\DeclareSIUnit\rpm{rpm}
\DeclareSIUnit\mz{m/z}

% Maths commands
\newcommand{\appr}{{\mathord{\sim}}}
\providecommand{\abs}[1]{\lvert#1\rvert}
\providecommand{\norm}[1]{\lVert#1\rVert}

% Nomenclature List
\makenomenclature

\renewcommand{\cftfignumwidth}{1.5cm}
\renewcommand{\cfttabnumwidth}{1.5cm}

