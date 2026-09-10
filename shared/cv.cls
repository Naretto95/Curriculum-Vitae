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
\RequirePackage{ifthen}
\RequirePackage{marvosym}
\RequirePackage{parskip}
\RequirePackage[utf8]{inputenc} % Required for inputting international characters
\RequirePackage[default,lf]{raleway} % lf = lining figures, so all digits share one uniform height

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

% Shared rule-length calculation for \profilesection and \cvsection: given a
% built box (already \sbox'd), sets \TotalSectionLength to the line width
% remaining after its *actual measured width* (\wd), plus a small fixed
% visual gap -- no guessed fudge factor, so it can't drift out of sync with
% box padding again.
\newcommand\@cvsectionrulewidth[1]{%
	\setlength{\TotalSectionLength}{\linewidth}%
	\addtolength{\TotalSectionLength}{-\wd#1}%
	\addtolength{\TotalSectionLength}{-2pt}%
}

\newsavebox{\@cvprofilebox}
\newcommand{\profilesection}[1]{%
	\vspace{8pt}%
	\sbox{\@cvprofilebox}{\Large\setlength{\fboxrule}{1pt}\fcolorbox{mainblue}{white}{\textcolor{black!80}{#1}}}%
	\@cvsectionrulewidth{\@cvprofilebox}%
	% Same measured-box centering technique as \cvsection below, instead of
	% a tikz node -- tikz nodes reserve a generic descender slot for their
	% text regardless of whether the actual content has any descenders,
	% which made text sit visibly high in the old box.
	\noindent{\color{black!80}\usebox{\@cvprofilebox}\ \rule[\dimexpr(\ht\@cvprofilebox-\dp\@cvprofilebox)/2-0.5pt\relax]{\TotalSectionLength}{1pt}}%
}

\newsavebox{\@cvsectionbox}
\newcommand{\cvsection}[1]{%
	\sbox{\@cvsectionbox}{\large\colorbox{mainblue}{\textcolor{white}{\MakeUppercase{\textbf{#1}}}}}%
	\@cvsectionrulewidth{\@cvsectionbox}%
	% Center the rule on the box's actual measured height rather than a
	% hard-coded offset, so it stays centered regardless of font metrics
	{\color{black!80} \usebox{\@cvsectionbox}\ \rule[\dimexpr(\ht\@cvsectionbox-\dp\@cvsectionbox)/2-0.5pt\relax]{\TotalSectionLength}{1pt}}% Print the title and auto-width rule
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
\@newcvfield{profilepic}
\@newcvfield{cvname}
\@newcvfield{cvjobtitle}

% Sidebar section labels (override with \renewcommand in the template to localize)
\newcommand{\cvskillslabel}{Skills}
\newcommand{\cvlanguageslabel}{Languages}

% Command for printing the contact information icons. minimum size forces
% every badge to the same fixed diameter regardless of which glyph is
% inside -- different Marvosym icons have different natural proportions, so
% without it each circle auto-sizes to its own glyph and they come out
% visibly inconsistent. Uses an absolute unit (not em) so it doesn't scale
% with whatever font size happens to be active when \icon is called.
\newcommand*\icon[1]{\tikz[baseline=(char.base)]{\node[shape=circle,draw,inner sep=1pt,minimum size=9pt, fill=mainblue,mainblue,text=white] (char) {#1};}}

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

% Helper: declare a skill-bar field <name> as a one-argument macro that
% stores its skill list and, once called, re-expands to the rendered bars
% -- same self-storing pattern as \@newcvfield, but rendered through
% \@cvskillbars instead of returned as-is. This is what lets \skills and
% \skillsbis share one implementation instead of two hand-duplicated macros.
\newcommand\@newcvskills[1]{%
	\expandafter\newcommand\csname #1\endcsname[1]{%
		\expandafter\renewcommand\csname #1\endcsname{\@cvskillbars{##1}}%
	}%
}

\@newcvskills{skills}    % primary skill bars (e.g. technical skills)
\@newcvskills{skillsbis} % secondary skill bars (e.g. languages)

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
			\ifthenelse{\equal{\cvdate}{}}{}{\textsc{\Large\icon{\Info}\strut} & \cvdate\\}
			\ifthenelse{\equal{\cvaddress}{}}{}{\textsc{\Large\icon{\Letter}\strut} & \cvaddress\\}
			\ifthenelse{\equal{\cvnumberphone}{}}{}{\textsc{\Large\icon{\Telefon}\strut} & \cvnumberphone\\}
			\ifthenelse{\equal{\cvsite}{}}{}{\textsc{\Large\icon{\Mundus}\strut} & \cvsite\\}
			\ifthenelse{\equal{\cvsitebis}{}}{}{\textsc{\Large\icon{\Info}\strut} & \cvsitebis\\}
			\ifthenelse{\equal{\cvmail}{}}{}{\textsc{\Large\icon{@}\strut} & \href{mailto:\cvmail}{\cvmail}}
		\end{tabular}

		%------------------------------------------------

		\profilesection{\cvskillslabel}

        \skills

		%------------------------------------------------

		\profilesection{\cvlanguageslabel}

		\skillsbis

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