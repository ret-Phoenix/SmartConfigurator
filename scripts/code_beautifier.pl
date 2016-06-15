#$ENGINE PerlScript
#$NAME CodeBeautifier
#для использования скрипта в OpenConf раскомментируйте две предыдущие строчки


#Автор - Диркс Алексей mailto:adirks@ngs.ru
#
#Эта программа является свободным программным обеспечением. Вы можете
#распространять и (или) модифицировать ее на условиях GNU Generic Public License.
#
#Данная программа распространяется с надеждой оказаться полезной, но
#БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, в том числе без гарантий пригодности для продажи или
#каких-либо других практических целей.
#
#С полным текстом лицензии на английском языке можно ознакомитсья по адресу
#http://www.gnu.org/licenses/gpl.txt или в файле
#gnugpl.eng.txt
#
#С русским переводом лицензии можно ознакомиться по адресу
#http://gnu.org.ru/gpl.html или в файле
#gnugpl.rus.txt
#
#Вы должны получить копию GNU Generic Public License вместе с копией этой программы.
#Если это не так - сообщите об этом авторам (mailto:adirks@ngs.ru , mailto:fe@alterplast.ru) или напишите
#Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

use vars qw/ $InOpenConf /;
$InOpenConf = 1 if( defined $Configurator);

use strict "vars"; #Запретим использовать необъявленные переменные
use locale;
use POSIX qw(locale_h);
use Getopt::Long;
use File::Find; #package для рекурсивного обхода каталогов

#Объявим глобальные переменные
use vars qw/ $tab_size
	$blank_after_proc $blank_before_endproc $blank_after_endproc $procname_after_endproc
	$blank_after_if $blank_before_elseif $blank_before_endif
	$blank_after_while $blank_before_wend
	$space_around_ops /;
use vars qw/ $pat_comment $pat_proc $pat_endproc /;
use vars qw/ $file_name $root_dir $keep_old_files /;
use vars qw/ $line $line_number $trimmed_line $state @states $level /;
use vars qw/ $proc_name $proc_start /;
use vars qw/ $in_string $skip_blanks $blank_lines $unended_operator/;
use vars qw/ $FormattedText /;

############################################################################
##       Настройки форматирования кода      ################################
$tab_size = 4;
$blank_after_proc = 0;      #Пустая строка в начале процедуры/функции
$blank_before_endproc = 0;  #Пустая строка в конце процедуры/функции
$blank_after_endproc = 1;   #Пустая строка после процедуры/функции
$procname_after_endproc = 30;#Имя метода в комментариях после завершения  (например  КонецПроцедуры //ПриОткрытии)
                            #Значение этой переменной - это количество строк, после которого метод считается 
                            #"большим", и нужно вставлять комментарий. Если размер метода меньше указанного, то 
                            #комментарий убирается
                            #Отрицательное значение - комментарии останутся как есть
$blank_after_if = 0;        #Пустая строка в начале блока 'Если'
$blank_before_elseif = 0;   #Пустая строка перед 'Иначе', 'ИначеЕсли'
$blank_before_endif = 0;    #Пустая строка перед 'КонецЕсли'
$blank_after_while = 0;     #Пустая строка в начале циклов 'Пока' и 'Для'
$blank_before_wend = 0;     #Пустая строка в конце циклов 'Пока' и 'Для'
$space_around_ops = 1;      #Пробелы около операторов и после запятых
############################################################################

$pat_comment = "\/\/.*"; #EOL comment pattern
$pat_proc = "Функция|Function|Процедура|Procedure";
$pat_endproc = "КонецФункции|EndFunction|КонецПроцедуры|EndProcedure";

my $usage = <<EOF
Использование:
   perl code_beautifier.pl [параметры]
Параметры могут быть:
   -h|--help  - этот текст
   -d|--dir <dir>  - каталог, откуда начнётся поиск программных модулей для форматирования (*.1S).
       По умолчанию поиск начинается с текущего каталога.
   -f|--file <file>  - имя файла, который нужно отформатировать. Если задан и каталог и имя файла,
       то отформатирован будет только файл.
   -k|--keep  - сохраняет исходные модули нетрнутыми, изменения записываются в файлы *.new.1S
EOF
;

$root_dir = '.';

#################################################################################
#################################################################################
main();  #для использования как OpenConf скрипт эту строчку надо закомментировать
#################################################################################
#################################################################################


sub main
{
	return if( $InOpenConf );
	
	die wintodos($usage) unless GetOptions("dir|d=s" => \$root_dir, "file|f=s" => \$file_name, "keep|k" => \$keep_old_files);

	if( $file_name )
	{
		$File::Find::name = $file_name;
		$_ = $file_name;
		BeautifyModule();
	}
	else
	{
		find(\&BeautifyModule, $root_dir);
	}
}

sub Beautify_OpenConf
{
	my $Text = shift;
	my @Lines = split(/\r\n/, $Text, -1);
	_BeautifyModule(@Lines);
	#Message("'$FormattedText'");
	$FormattedText =~ s/\n/\r\n/g;
	return $FormattedText;
}

sub perror
{
	if( $InOpenConf )
	{
		Message(shift, 1);
	}
	else
	{
		print STDERR wintodos(shift), "\n";
	}
}


sub _BeautifyModule
{
	my @Lines = @_;
	$line_number = 0;
	my $NLines = @_;

	$FormattedText = "";
	$state = "module";
	$level = 0;
	pop @states while (scalar @states) > 0;
	$skip_blanks = 0;
	$blank_lines = 0;
	$in_string = 0;
	$unended_operator = 0;
	my $module_head = 1;

	foreach $line (@Lines)
	{
		$line_number++;
		$line =~ s/[\r\n]//g; #уберём завершающие \n и \r, если они там есть
		$trimmed_line = $line;
		$trimmed_line =~ s/^\s*(.*?)\s*$/$1/;
		#print "$state, $level, $skip_blanks (blanks = $blank_lines), unended = $unended_operator : '$trimmed_line'\n";

		if( not $trimmed_line )
		{
			$blank_lines++ if not $skip_blanks;
			next;
		}

		if( $InOpenConf ) { Status("$line_number / $NLines"); }	

		my $keyword_match = 0;
		
		if( $state eq "module" )
		{
			$keyword_match = 1 if check_proc_begin() or check_if() or check_cycle() or check_try();
			if( $keyword_match and $module_head )
			{
				$FormattedText .= "\n" if $blank_lines;
				$module_head = 0;
			}	
		}
		elsif( $state eq "proc" )
		{
			$keyword_match = 1 if check_end_proc() or check_if() or check_cycle() or check_try() or check_proc_begin();
		}
		elsif( $state eq "if_multiline" )
		{
			check_multiline_if();
			$keyword_match = 1;
		}
		elsif( $state eq "if" )
		{
			$keyword_match = 1 if check_if() or check_cycle() or check_elsif() or check_endif() or check_try() or check_proc_begin();
		}
		elsif( $state eq "try" )
		{
			$keyword_match = 1 if check_try() or check_if() or check_cycle();
		}
		elsif( $state eq "cycle" )
		{
			$keyword_match = 1 if check_cycle() or check_endcycle() or check_if() or check_try() or check_proc_begin();
		}

		if( $keyword_match )
		{
			#$blank_lines = 0;
			$unended_operator = 0;
			next;
		}

		$unended_operator = 0 if $in_string and $unended_operator == 0;

		#Message("$line: $state  $skip_blanks  $blank_lines");
		$FormattedText .= "\n" if $blank_lines;
		$blank_lines = 0;
		if( $unended_operator )
			{ print_line( offset(1), format_expr($trimmed_line) ); }
		else
			{ print_line( format_expr($trimmed_line) ); }
		$skip_blanks = 0;

		if( not $in_string )
		{
			if( $trimmed_line =~ m/^.*;(\s*$pat_comment)*$/ )
				{$unended_operator = 0;}
			elsif( $trimmed_line =~ m/^$pat_comment$/ )
				{$unended_operator = 0;}
			else
				{$unended_operator++;}
		}
	}

	if( $InOpenConf ) { Status(""); }	
	return $FormattedText;
}

sub BeautifyModule
{
	my $FName = $_; #File::Find складывает в $_ имя текущего файла
	if( $file_name )
	{
		$FName = $file_name;
	}
	else
	{
		return unless $FName =~ m/^(.*)(\.1S)$/i; #нам нужны только файлы с расширением 1S
		return if $FName =~ m/^(.*)(\.new\.1S)$/i; #нам не нужны файлы с расширением new.1S
	}
	$FName =~ m/^(.*)(\.\S*)$/i;
	my $newFName = "$1.new$2";

	perror($File::Find::name);
	open IN, "< $FName";
	open OUT, "> $newFName";

	print OUT _BeautifyModule((<IN>));

	close OUT;
	close IN;
	if( not $keep_old_files )
	{
		if( !rename($newFName, $FName) )
		{
			print wintodos("Can't move $newFName to $FName: $!\n");
		}
	}
}

sub format_op_spaces
{
	my $lspace = shift;
	my $op = shift;
	my $rspace = shift;

	return ("", "") if not $space_around_ops;
	$lspace = " " if not $lspace and $op ne ",";
	$rspace = " " if not $rspace;
	return ($lspace, $rspace);
}

sub format_expr
{
	my $expr = shift;
	my $formatted = "";
	my $lspace = "";
	my $rspace = "";
	my $op = "";

	if( $expr =~ m/^(\s+)(.*)$/ )
	{
		$formatted = $1;
		$expr = $2;
	}
	#$expr =~ s/^((.*?)("[^"]*")*)(\s*$pat_comment)*$/$1/;
	#my $eol_comment = $2;
	my $eol_comment = '';

	while( length($expr) > 0 )
	{
		if( $in_string )
		{
			my $c = substr($expr, 0, 1);
			if( $c eq '"' )
			{
				if( substr($expr, 1, 1) eq '"' )
				{
					$formatted .= '"';
					$expr = substr($expr, 1);
				}
				else
				{
					$in_string = 0;
				}
			}
			$formatted .= $c;
			$expr = substr($expr, 1);
		}
		elsif( substr($expr, 0, 1) eq '"' )
		{
			$formatted .= $lspace . '"';
			$expr = substr($expr, 1);
			$in_string = 1;
		}
		elsif( substr($expr, 0, 1) eq '/' and substr($expr, 1, 1) eq '/') #EOL comment
		{
			$eol_comment = $expr;
			$expr = '';
		}
		elsif( $expr =~ m/^\s*;(.*)$/i ) #ending  ';'
		{
			$expr = $1;
			$formatted .= ";";
			($lspace, $rspace) = ("", "");
		}	
		elsif( $expr =~ m/^(=|\(|\+|Return|Возврат)(\s*)-\s*(.*)$/i ) #unary minus
		{
			$op = $1;
			$rspace = $2;
			$expr = $3;
			($lspace, $rspace) = format_op_spaces($lspace, $op, $rspace);
			#Message("'$lspace'  '$op'  '$rspace'     '$expr'");
			$formatted .= $lspace . $op . $rspace . "-";

			($lspace, $rspace) = ("", "");
		}	
		elsif( $expr =~ m/^(<>|<=|>=|,|=|\+|-|\*|\/|%|<|>)(\s*)(.*)$/i )
		{
			$op = $1;
			$rspace = $2;
			$expr = $3;

			($lspace, $rspace) = format_op_spaces($lspace, $op, $rspace);
			$rspace = "" if $op eq "," and substr($expr, 0, 1) eq ","; #2 запятые подряд - без пробела

			$formatted .= $lspace . $op . $rspace;

			($lspace, $rspace) = ("", "");
		}
		elsif( $expr =~ m/^(\)\s*)(И|AND|ИЛИ|OR)(\s*\()(.*)$/i )
		{
			$op = uc($2);
			$lspace = substr($1, 1);
			$rspace = substr($3, 0, length($3) - 1);
			($lspace, $rspace) = format_op_spaces($lspace , $op, $rspace);

			$formatted .= ")" . $lspace . $op . $rspace . "(";
			$expr = $4;

			$lspace = "";
			$rspace = "";
		}
		elsif( not $formatted and $expr =~ m/^(И|AND|ИЛИ|OR)(\s*\()(.*)$/i )
		{
			$op = uc($1);
			$rspace = substr($2, 0, length($2) - 1);
			($lspace, $rspace) = format_op_spaces($lspace , $op, $rspace);

			$formatted .= $op . $rspace . "(";
			$expr = $3;

			$lspace = "";
			$rspace = "";
		}
		elsif( $expr =~ m/^(\)\s*)(И|AND|ИЛИ|OR)$/i )
		{
			$op = uc($2);
			$lspace = substr($1, 1);
			$rspace = "";
			($lspace, $rspace) = format_op_spaces($lspace , $op, $rspace);

			$formatted .= ")" . $lspace . $op;
			$expr = "";

			$lspace = "";
			$rspace = "";
		}
		elsif( $expr =~ m/^(\s+)(.*)$/ )
		{
			$rspace = $1;
			$expr = $2;
		}
		else
		{
			$formatted .= $lspace;
			$formatted .= substr($expr, 0, 1);
			$expr = substr($expr, 1);
			$rspace = "";
		}

		$lspace = $rspace;
	}
	$formatted .= $rspace;
	$formatted .= $eol_comment;

	return $formatted;
}

sub check_proc_begin
{
	if( $trimmed_line =~ m/^($pat_proc)(\s+(\S+)\(.*\)\s*)(Экспорт|Export)*(.*)($pat_endproc)(\s*)($pat_comment)*$/i )
	{
		perror("    Синтаксические ошибки в процедуре '$proc_name'") if $level > 0;
		$proc_name = "";
		$proc_start = 0;
		print_line(ucfirst($1), format_expr($2), ucfirst($4), $5, ucfirst($6), $7, $8);
		$level = 0;
		$unended_operator = 0;
		return 1;
	}
	elsif( $trimmed_line =~ m/^($pat_proc)(\s+)(\S+)(\s*\(.*\))((\s+(Экспорт|Export|Далее|Forward))*)(;*)(\s*$pat_comment)*$/i )
	{
		perror("    Синтаксические ошибки в процедуре '$proc_name'") if $level > 0;
		$proc_name = $3;
		$proc_start = $line_number;
		$level = 0;
		print_line(ucfirst($1), $2, $3, format_expr($4), ucfirst($5), $8, $9);
		if( not $5 =~ m/Далее|Forward/i )
		{
			push @states, $state;
			$state = "proc";
			$level = 1;
			$FormattedText .= "\n" if $blank_after_proc;
		}
		else
		{
			$FormattedText .= "\n" if $blank_after_endproc;
		}
		$skip_blanks = 1;
		$blank_lines = 0;
		$unended_operator = 0;
		return 1;
	}
	return 0;
}

sub check_end_proc
{
	if( $trimmed_line =~ m/^($pat_endproc)([^\/\s]*)((?:\s*$pat_comment)*)$/i )
	{
		$FormattedText .= "\n" if $blank_before_endproc;

		perror("    Синтаксические ошибки в процедуре '$proc_name'") if $level != 1;
		$level = 0;
		my ($endproc, $text_after, $comment) = ($1, $2, $3);
		
		if( $procname_after_endproc >= 0 )
		{
			my $proc_lines = $line_number - $proc_start + 1;
			my $need_comment = $proc_lines >= $procname_after_endproc;
			if( !$need_comment and !$text_after and ($comment =~ m/^\s*\/\/\s*($proc_name)?\s*\(?\s*\)?\s*$/i) )
			{
				print_line(ucfirst($endproc));
			}
			elsif( $need_comment and !$text_after and ($comment =~ m/^\s*$/) )
			{
				print_line(ucfirst($endproc), " //$proc_name()");
			}
			else
			{
				print_line(ucfirst($endproc), format_expr($text_after), $comment);
			}
		}
		else
		{
			print_line(ucfirst($endproc), format_expr($text_after), $comment);
		}
		
		$state = pop @states;
		$proc_name = "";
		$proc_start = 0;
		$FormattedText .= "\n" if $blank_after_endproc;
		$skip_blanks = 1;
		$blank_lines = 0;
		return 1;
		$unended_operator = 0;
	}
	return 0;
}

sub check_if
{
	if( $trimmed_line =~ m/^(Если|If)([(\s].*[)\s])(Тогда|Then)(\s.*)(КонецЕсли|EndIf)(;*.*?)(\s*$pat_comment)*$/i ) #весь if в одну строчку
	{
		$FormattedText .= "\n" if $blank_lines;
		print_line(ucfirst($1), format_expr($2), ucfirst($3), format_expr($4), ucfirst($5), format_expr($6), $7);
	}
	elsif( $trimmed_line =~ m/^(Если|If)([(\s].*[)\s])(Тогда|Then)(\s*[\s;].*?){0,1}(\s*$pat_comment)*$/i )
	{
		$FormattedText .= "\n" if $blank_lines;
		print_line(ucfirst($1), format_expr($2), ucfirst($3), format_expr($4), $5);
		push @states, $state;
		$state = "if";
		$level++;
		$skip_blanks = 1;
		$blank_lines = 0;
		$FormattedText .= "\n" if $blank_after_if;
	}
	elsif( $trimmed_line =~ m/^(Если|If)([(\s].*)$/i ) #then на другой строке
	{
		$FormattedText .= "\n" if $blank_lines;
		print_line(ucfirst($1), format_expr($2));
		push @states, $state;
		push @states, "if";
		$state = "if_multiline";
		$skip_blanks = 1;
		$blank_lines = 0;
	}
	else
	{
		return 0;
	}

	$unended_operator = 0;
	return 1;
}

sub check_multiline_if
{
	if( $trimmed_line =~ m/^$pat_comment$/i )
	{
		$FormattedText .= offset($level + 1) . " " . $trimmed_line . "\n";
	}
	elsif( $trimmed_line =~ m/^(.*[)\s])(Тогда|Then)(\s*$pat_comment)*$/i )
	{
		$state = pop @states;
		$FormattedText .= offset($level + 1) . " " . format_expr($1) . "\n" if $1;
		$FormattedText .= offset($level) . ucfirst($2) . "\n" if $2;
		$level++;
	}
	elsif( $trimmed_line =~ m/^(Тогда|Then)(\s*$pat_comment)*$/i )
	{
		$state = pop @states;
		$FormattedText .= offset($level) . ucfirst($1) . $2 . "\n";
		$level++;
	}
	else
	{
		$FormattedText .= offset($level + 1) . " " . format_expr($trimmed_line) . "\n";
	}
	$skip_blanks = 1;
}

sub check_elsif
{
	if( $trimmed_line =~ m/^(Иначе|Else)(\s.*?){0,1}(\s*$pat_comment)*$/i )
	{
		$level--;
		$FormattedText .= "\n" if $blank_before_elseif;
		print_line(ucfirst($1), format_expr($2), $3);
	}
	elsif( $trimmed_line =~ m/^(ИначеЕсли|ElsIf)([(\s].*[)\s])(Тогда|Then)(\s.*?){0,1}(\s*$pat_comment)*$/i )
	{
		$level--;
		$FormattedText .= "\n" if $blank_before_elseif;
		print_line(ucfirst($1), format_expr($2), ucfirst($3), format_expr($4), ucfirst($5), $6, $7);
	}
	elsif( $trimmed_line =~ m/^(ИначеЕсли|ElsIf)([(\s].*)$/i ) #then на другой строке
	{
		$level--;
		$FormattedText .= "\n" if $blank_before_elseif;
		print_line(ucfirst($1), format_expr($2));
		
		push @states, $state;
		$level--;
		$state = "if_multiline";
	}
	else
	{
		return 0;
	}

	$level++;
	$skip_blanks = 1;
	$blank_lines = 0;

	return 1;
}


sub check_endif
{
	if( $trimmed_line =~ m/^(КонецЕсли|EndIf)(;*.*?)($pat_comment)*$/i )
	{
		$level--;
		$FormattedText .= "\n" if $blank_before_endif;
		print_line(ucfirst($1), format_expr($2), $3);
		$state = pop @states;
		$skip_blanks = 0;
		$blank_lines = 0;
		return 1;
	}
	return 0;
}

sub check_cycle
{
	if( $trimmed_line =~ m/^(Для|For)(\s.*\s)(По|To)(\s.*\s)(Цикл|Do)(\s*$pat_comment)*$/i )
	{
		$FormattedText .= "\n" if $blank_lines;
		print_line(ucfirst($1), format_expr($2), ucfirst($3), format_expr($4), ucfirst($5), $6);
	}
	elsif( $trimmed_line =~ m/^(Пока|While)([\s("']*.*?[\s)"'])(Цикл|Do)(\s*$pat_comment)*$/i )
	{
		$FormattedText .= "\n" if $blank_lines;
		print_line(ucfirst($1), format_expr($2), ucfirst($3), $4);
	}
	else
	{
		return 0;
	}

	$level++;
	push @states, $state;
	$state = "cycle";
	$skip_blanks = 1;
	$blank_lines = 0;
	$FormattedText .= "\n" if $blank_after_while;
	return 1;
}

sub check_endcycle
{
	if( $trimmed_line =~ m/^(КонецЦикла|EndDo)(;*.*?)(\s*$pat_comment)*$/i )
	{
		$state = pop @states;
		$level--;
		$FormattedText .= "\n" if $blank_before_wend;
		print_line(ucfirst($1), format_expr($2), $3);
		$blank_lines = 0;
		return 1;
	}
	return 0;
}


sub	check_try
{
	if( $trimmed_line =~ m/^(Попытка|Try)(\s*$pat_comment)*$/i )
	{
		$FormattedText .= "\n" if $blank_lines;
		print_line(ucfirst($1), $2);
		$level++;
		push @states, $state;
		$state = "try";
		$skip_blanks = 1;
		$blank_lines = 0;
		return 1;
	}
	elsif( $trimmed_line =~ m/^(Исключение|Except)(\s*$pat_comment)*$/i )
	{
		$level--;
		print_line(ucfirst($1), $2);
		$level++;
		$skip_blanks = 1;
		$blank_lines = 0;
		return 1;
	}
	elsif( $trimmed_line =~ m/^(КонецПопытки|EndTry)(;*.*?)(\s*$pat_comment)*$/i )
	{
		$state = pop @states;
		$level--;
		print_line(ucfirst($1), format_expr($2), $3);
		$blank_lines = 0;
		$skip_blanks = 0;
		return 1;
	}
	elsif( $trimmed_line =~ m/^(Исключение|Except)\s+(КонецПопытки|EndTry)(;*.*?)(\s*$pat_comment)*$/i )
	{
		$state = pop @states;
		$level--;
		print_line(ucfirst($1), " ", ucfirst($2), format_expr($3), $4);
		$blank_lines = 0;
		$skip_blanks = 0;
		return 1;
	}
	return 0;
}

##################################################################
sub offset
{
	my $i = shift;
	my $offset = "";
	$offset .= "\t" while $i-- > 0;
	return $offset;
}

sub print_line
{
	$FormattedText .= offset($level);
	foreach (@_)
	{
		$FormattedText .= $_;
	}	
	$FormattedText .= "\n";
}

 sub wintodos {
	my $win_chars = "\xA8\xB8\xB9\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF";
	my $dos_chars = "\xF0\xF1\xFC\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF";
	$_ = shift;
	return $_ if $^O eq "cygwin";
	eval("tr/$win_chars/$dos_chars/");
	return $_;
}
