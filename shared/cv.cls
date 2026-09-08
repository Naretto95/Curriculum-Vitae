\ProvidesClass{cv}[2017/01/08 CV class]
\LoadClass{article}
\NeedsTeXFormat{LaTeX2e}

%----------------------------------------------------------------------------------------
%	 REQUIRED PACKAGES
%----------------------------------------------------------------------------------------

\RequirePackage[T1]{fontenc}
\RequirePackage{tikz}
\RequirePackage{xcolor}
\RequirePackage[absolute,overlay]{textpos}
\RequirePackage{ragged2e}
\RequirePackage{etoolbox}
\RequirePackage{ifmtarg}
\RequirePackage{ifthen}
\RequirePackage{pgffor}
\RequirePackage{marvosym}
\RequirePackage{parskip}
\RequirePackage[utf8]{inputenc} % Required for inputting international characters
\RequirePackage[default]{raleway}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

%----------------------------------------------------------------------------------------
%	 COLOURS
%----------------------------------------------------------------------------------------

% "white" is already provided by xcolor; only the custom palette needs defining
\definecolor{gray}{HTML}{333333}
\definecolor{sidecolor}{HTML}{E7E7E7}
\definecolor{mainblue}{HTML}{0E5484}
\definecolor{maingray}{HTML}{B9B9B9}

\renewcommand*\familydefault{\sfdefault} % Force the sans-serif version of any font used

%----------------------------------------------------------------------------------------
%	 MISC CONFIGURATIONS
%----------------------------------------------------------------------------------------

\pagestyle{empty} % Disable headers and footers

\setlength{\parindent}{0pt} % Disable paragraph indentation

%----------------------------------------------------------------------------------------
%	 SIDEBAR DEFINITIONS
%----------------------------------------------------------------------------------------

\setlength{\TPHorizModule}{1cm} % Left margin
\setlength{\TPVertModule}{1cm} % Top margin

\newlength\imagewidth
\newlength\imagescale
\pgfmathsetlength{\imagewidth}{5cm}
\pgfmathsetlength{\imagescale}{\imagewidth/600}

\newlength{\TotalSectionLength} % Define a new length to hold the remaining line width after the section title is printed
\newlength{\SectionTitleLength} % Define a new length to hold the width of the section title

% Shared width calculation for \profilesection and \cvsection: measures #1,
% then sets \TotalSectionLength to the line width remaining after it (minus
% the #2 fudge factor each rule needs to avoid an overfull box warning)
\newcommand\@cvsectionwidth[2]{%
	\settowidth{\SectionTitleLength}{#1}%
	\setlength{\TotalSectionLength}{\linewidth}%
	\addtolength{\TotalSectionLength}{-\SectionTitleLength}%
	\addtolength{\TotalSectionLength}{#2}%
}

\newcommand{\profilesection}[1]{
    \@cvsectionwidth{\Large #1}{-2pt} % optional small adjustment
    \vspace{8pt}%
    \noindent
    \begin{tikzpicture}[baseline=(textnode.base)]
        % Section title node
        \node[draw=mainblue, line width=1pt, fill=white, inner sep=3pt] (textnode) {\Large \textcolor{black!80}{#1}};
        % Black horizontal line starting at the right edge of the box
        \draw[black!80, line width=1pt]
            ([xshift=2pt]textnode.east) -- ++(\TotalSectionLength,0);
    \end{tikzpicture}%
}

\newcommand{\cvsection}[1]{%
	\@cvsectionwidth{\large {\textcolor{white}{\MakeUppercase{\textbf{#1}}}}}{-2.22221pt}% Modifier to remove overfull box warning
	{\color{black!80} \large \colorbox{mainblue}{\textcolor{white}{\MakeUppercase{\textbf{#1}}}}  \rule[0.15\baselineskip]{\TotalSectionLength}{1pt}}% Print the title and auto-width rule
}

% Helper: declare a CV info field <name> as a one-argument macro that stores
% its value and, once called, re-expands to that stored value with no
% argument (this is what lets \makeprofile check e.g. \equal{\cvdate}{})
\newcommand\@newcvfield[1]{%
	\expandafter\newcommand\csname #1\endcsname[1]{%
		\expandafter\renewcommand\csname #1\endcsname{##1}%
	}%
}

% Define custom commands for CV info
\@newcvfield{cvdate}
\@newcvfield{cvsitebis}
\@newcvfield{cvmail}
\@newcvfield{cvnumberphone}
\@newcvfield{cvaddress}
\@newcvfield{cvsite}
\@newcvfield{aboutme}
\@newcvfield{profilepic}
\@newcvfield{cvname}
\@newcvfield{cvjobtitle}

% Sidebar section labels (override with \renewcommand in the template to localize)
\newcommand{\cvskillslabel}{Skills}
\newcommand{\cvlanguageslabel}{Languages}

% Command for printing the contact information icons
\newcommand*\icon[1]{\tikz[baseline=(char.base)]{\node[shape=circle,draw,inner sep=1pt, fill=mainblue,mainblue,text=white] (char) {#1};}}

% Shared implementation for skill progress bars (used by \skills and \skillsbis)
\newcommand\@cvskillbars[1]{
	\begin{tikzpicture}
		\foreach [count=\i] \x/\y in {#1}{
			\draw[fill=maingray,maingray] (0,\i) rectangle (6,\i+0.4);
			\draw[fill=white,mainblue](0,\i) rectangle (\y,\i+0.4);
			\node [above right] at (0,\i+0.4) {\x};
		}
	\end{tikzpicture}
}

% Shared implementation for skill text (used by \skillstext and \skillstextbis)
\newcommand\@cvskilltext[1]{
	\begin{flushleft}
		\foreach [count=\i] \x/\y in {#1}{
			\x$ \star $\y
		}
	\end{flushleft}
}

% Command for printing skill progress bars
\newcommand\skills[1]{\renewcommand{\skills}{\@cvskillbars{#1}}}

% Command for printing skills text
\newcommand\skillstext[1]{\renewcommand{\skillstext}{\@cvskilltext{#1}}}

% Command for printing skill progress bars (second block, e.g. languages)
\newcommand\skillsbis[1]{\renewcommand{\skillsbis}{\@cvskillbars{#1}}}

% Command for printing skills text (second block, e.g. languages)
\newcommand\skillstextbis[1]{\renewcommand{\skillstextbis}{\@cvskilltext{#1}}}

%----------------------------------------------------------------------------------------
%	 SIDEBAR LAYOUT
%----------------------------------------------------------------------------------------

\newcommand{\makeprofile}{
	\begin{tikzpicture}[remember picture,overlay]
   		\node [rectangle, fill=sidecolor, anchor=north, minimum width=9cm, minimum height=\paperheight+1cm] (box) at (-5cm,0.5cm){};
	\end{tikzpicture}

	%------------------------------------------------

	\begin{textblock}{6}(0.5, 0.2)
			
		%------------------------------------------------
		
		\ifthenelse{\equal{\profilepic}{}}{}{
			\begin{center}
				\begin{tikzpicture}[x=\imagescale,y=-\imagescale]
					\clip (600/2, 567/2) circle (567/2);
					\node[anchor=north west, inner sep=0pt, outer sep=0pt] at (0,0) {\includegraphics[width=\imagewidth]{\profilepic}};
				\end{tikzpicture}
			\end{center}
		}

		%------------------------------------------------

		{\Huge\color{mainblue}\cvname}

		%------------------------------------------------

		{\Large\color{black!80}\cvjobtitle}

		%------------------------------------------------

		\renewcommand{\arraystretch}{1.6}
		\begin{tabular}{p{0.5cm} @{\hskip 0.5cm}p{5cm}}
			\ifthenelse{\equal{\cvdate}{}}{}{\textsc{\Large\icon{\Info}} & \cvdate\\}
			\ifthenelse{\equal{\cvaddress}{}}{}{\textsc{\Large\icon{\Letter}} & \cvaddress\\}
			\ifthenelse{\equal{\cvnumberphone}{}}{}{\textsc{\Large\icon{\Telefon}} & \cvnumberphone\\}
			\ifthenelse{\equal{\cvsite}{}}{}{\textsc{\Large\icon{\Mundus}} & \cvsite\\}
			\ifthenelse{\equal{\cvsitebis}{}}{}{\textsc{\Large\icon{\Info}} & \cvsitebis\\}
			\ifthenelse{\equal{\cvmail}{}}{}{\textsc{\large\icon{@}} & \href{mailto:\cvmail}{\cvmail}}
		\end{tabular}

		%------------------------------------------------
		
		%\ifthenelse{\equal{\aboutme}{}}{}{
		%	\profilesection{À propos}
		%	\begin{flushleft}
		%		\aboutme
		%	\end{flushleft}
		%}

		%------------------------------------------------

		\profilesection{\cvskillslabel}

        \skills
		\skillstext
		\scriptsize


		%------------------------------------------------

		\profilesection{\cvlanguageslabel}

		\skillsbis
		\skillstextbis
		\scriptsize

			
		%------------------------------------------------
			
	\end{textblock}
}

%----------------------------------------------------------------------------------------
%	 SECTION
%----------------------------------------------------------------------------------------

\renewcommand{\section}[1]{
	{%
		\color{gray}%
		\Large\sectioncolor{#1}%
	}
}

\renewcommand{\subsection}[1]{
	\par\vspace{.5\parskip}{%
		\large\color{gray} #1%
	}
	\par\vspace{.25\parskip}%
}

%----------------------------------------------------------------------------------------
%	 LONG LIST ENVIRONMENT
%----------------------------------------------------------------------------------------

\setlength{\tabcolsep}{0pt}

% New environment for the long list
\newenvironment{twenty}{%
	\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}ll}
}{%
	\end{tabular*}
}

\newcommand{\twentyitem}[4]{%
	#1&\parbox[t]{0.83\textwidth}{%
		\textcolor{gray}{\textbf{#2}}%*
		\hfill%
		{\footnotesize\textcolor{gray}{\textbf{#3}}}\\%
		#4\vspace{\parsep}%
	}\\
}

%----------------------------------------------------------------------------------------
%	 SMALL LIST ENVIRONMENT
%----------------------------------------------------------------------------------------

% Same table layout as \twenty, just with a shorter per-item command
\newenvironment{twentyshort}{\twenty}{\endtwenty}

\newcommand{\twentyitemshort}[2]{%
	#1&\parbox[t]{0.83\textwidth}{%
		\textbf{#2}%
	}\\
}

%----------------------------------------------------------------------------------------
%	 MARGINS AND LINKS
%----------------------------------------------------------------------------------------

\RequirePackage[left=7.6cm,top=0cm,right=1cm,bottom=0cm,nohead,nofoot]{geometry}

\RequirePackage{hyperref}