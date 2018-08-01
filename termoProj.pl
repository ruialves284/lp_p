% Rui Alves 65284
% Projeto LP
% IST 2017/2018
:- [puzzle_examples].

%-------------------------------------------------------------------------------%
%                         Predicados auxiliares gerais                          %
%-------------------------------------------------------------------------------%

% linha/2
% linha(Pos, X) afirma que X e a primeira coordenada da posicao Pos
linha((X,_), X).

% coluna/2
% coluna(Pos, Y) afirma que Y e a segunda coordenada da posicao Pos
coluna((_,Y), Y).

% dim/2
% dim(Puz, Dim) afirma que Dim e a dimensao do puzzle Puz (numero de colunas/linhas)
dim(Puz, Dim) :-
  nth1(3, Puz, Max_Colunas),
  length(Max_Colunas, Dim).

% combinacoes/3
% combinacoes(Total, Lista, Sublista) afirma que a lista Sublista, de Total elementos,
%   e sublista da lista Lista.
combinacoes(0, _, []).
combinacoes(N, L, [E | C_L_E]) :-
  N > 0,
  append(_, [E | L_apos_E], L),
  N_1 is N - 1,
  combinacoes(N_1, L_apos_E, C_L_E).

%-------------------------------------------------------------------------------%
%                                   PROPAGA                                     %
%-------------------------------------------------------------------------------%

% propaga/3
% propaga(Puz, Pos, Posicoes) dado o puzzle Puz, afirma que o preenchimento
%   da posicao Pos implica o preenchimento de todas as posicoes em Posicoes
propaga(Puz, Pos, Posicoes) :-
  nth1(1, Puz, Lista_Termometros),
  procura_termometro(Lista_Termometros, Pos, Posicoes).

%-----------------------------------Auxiliares----------------------------------%

% procura_termometro/3
% procura_termometro(Termometro, Pos, Posicoes) dado a lista Termometro,
%   se a posicao Pos esta contida no Termometro, afirma que a lista Posicoes e
%   constituida pelas posicoes do Termometro do inicio ate a posicao Pos, inclusive
procura_termometro([Termometro | _], Pos, Posicoes) :-
  member(Pos, Termometro), % Pos pertence ao Termometro,
  verifica_prioridade(Termometro, Pos, [], Posicoes).
procura_termometro([Termometro | Resto_Termometros], Pos, Posicoes) :-
  \+ member(Pos, Termometro), % Pos nao pertence ao Termometro
  procura_termometro(Resto_Termometros, Pos, Posicoes).

% verifica_prioridade/4
% verifica_prioridade(Termometro, Pos, Posicoes_Anteriores, Posicoes) dada a lista
%   Termometro, afirma que a lista Posicoes_Anteriores e constituida por todos os
%   elementos desde o inicio da lista Termometro ate a posicao Pos, inclusive
verifica_prioridade([Head | Tail], Pos, Posicoes_Anteriores, Posicoes) :-
  Head \== Pos,     % Pos nao e a primeira posicao do Termometro
  append(Posicoes_Anteriores, [Head], Novas_Posicoes_Anteriores),
  verifica_prioridade(Tail, Pos, Novas_Posicoes_Anteriores, Posicoes).
verifica_prioridade([Head | _], Pos, Posicoes_Anteriores, Posicoes) :-
  Head == Pos,      % Pos e a primeira posicao do Termometro
  append(Posicoes_Anteriores, [Head], Posicoes_Nao_Ordenadas),
  sort(Posicoes_Nao_Ordenadas, Posicoes).

%-------------------------------------------------------------------------------%
%                         NAO ALTERA LINHAS ANTERIORES                          %
%-------------------------------------------------------------------------------%

% nao_altera_linhas_anteriores/3
% nao_altera_linhas_anteriores(Posicoes, L, Ja_Preenchidas) dada a lista de posicoes
%   Posicoes que e uma possibilidade para preencher a linha L, afirma que todas as suas posicoes
%   pertencendo a linhas anteriores a L, pertencem a lista de posicoes Ja_Preenchidas
nao_altera_linhas_anteriores([], _, _).
nao_altera_linhas_anteriores([Head | Tail], L, Ja_Preenchidas) :-
  linha(Head, Linha),
  Linha >= L,                       % linha L ou seguintes, nao ha verificacao a fazer
  nao_altera_linhas_anteriores(Tail, L, Ja_Preenchidas).
nao_altera_linhas_anteriores([Head | Tail], L, Ja_Preenchidas) :-
  linha(Head, Linha),
  Linha < L,                        % linha anterior a L
  member(Head, Ja_Preenchidas),     % verifica se Head e membro da Ja_Preenchidas
  nao_altera_linhas_anteriores(Tail, L, Ja_Preenchidas).

%-------------------------------------------------------------------------------%
%                               VERIFICA PARCIAL                                %
%-------------------------------------------------------------------------------%

% verifica_parcial/4
% verifica_parcial(Puz, Ja_Preenchidas, Dim, Poss) dado o puzzle Puz e a sua dimensao Dim
%   verifica que uma dada possibilidade Poss para preencher uma determinada linha nao
%   faz com que os limites das colunas de Puz sejam ultrapassados, tendo em conta a
%   lista de posicoes Ja_Preenchidas
verifica_parcial(_, _, _, []).
verifica_parcial(Puz, Ja_Preenchidas, Dim, Poss) :-
  append(Ja_Preenchidas, Poss, Novas_Ja_Preenchidas_Nao_Ordenadas),
  sort(Novas_Ja_Preenchidas_Nao_Ordenadas, Novas_Ja_Preenchidas),
  verifica_colunas(Puz, Novas_Ja_Preenchidas, Dim).

%-----------------------------------Auxiliares----------------------------------%

% verifica_colunas/3
% verifica_colunas(Puz, Ja_Preenchidas, Dim) dado o puzzle Puz e a lista de posicoes
%   Ja_Preenchidas, afirma que o limite de todas as colunas de Puz e respeitado,
%   iterativamente, partindo da ultima coluna (indice Dim)
verifica_colunas(_, _, 0).
verifica_colunas(Puz, Ja_Preenchidas, Coluna) :-
  nth1(3, Puz, Max_Colunas),
  nth1(Coluna, Max_Colunas, Max),
  conta_pos_na_coluna(Ja_Preenchidas, Coluna, Contador),
  !, % contagem de posicoes na coluna nao muda
  Contador =< Max,
  Coluna_Anterior is Coluna-1,
  verifica_colunas(Puz, Ja_Preenchidas, Coluna_Anterior).

% conta_pos_na_coluna/3
% conta_pos_na_coluna(Ja_Preenchidas, Coluna, Contador) dada a lista de posicoes
%   Ja_Preenchidas, afirma que o numero de posicoes que pertencem a coluna Coluna
%   e igual a Contador.
conta_pos_na_coluna(Ja_Preenchidas, Coluna, Contador) :-
  conta_pos_na_coluna(Ja_Preenchidas, Coluna, 0, Contador).
conta_pos_na_coluna([], _, Ac, Ac).
conta_pos_na_coluna([Head_Ja_P | Tail_Ja_P], Coluna, Ac, Contador) :-
  coluna(Head_Ja_P, Col_Pos),
  Col_Pos \== Coluna,       % Coluna da posicao diferente da coluna, segue
  conta_pos_na_coluna(Tail_Ja_P, Coluna, Ac, Contador).
conta_pos_na_coluna([Head_Ja_P | Tail_Ja_P], Coluna, Ac, Contador) :-
  coluna(Head_Ja_P, Col_Pos),
  Col_Pos =:= Coluna,       % Coluna da posicao e igual a coluna
  Ac_N is Ac + 1,           % incrementa contador
  conta_pos_na_coluna(Tail_Ja_P, Coluna, Ac_N, Contador).

%-------------------------------------------------------------------------------%
%                             POSSIBILIDADES LINHA                              %
%-------------------------------------------------------------------------------%

% possibilidades_linha/5
% possibilidades_linha(Puz, Posicoes_Linha, Total, Ja_Preenchidas, Possibilidades_L)
%   dado o puzzle Puz, afirma que a lista de possibilidades_L e a lista de possibilidades
%   de posicoes a preencher para preencher o Total de posicoes necessarias na linha com
%   lista de posicoes Posicoes_Linha, tendo em conta possiveis posicoes ja preenchidas por
%   escolhas anteriores, presentes em Ja_Preenchidas.
possibilidades_linha(Puz, Posicoes_Linha, Total, Ja_Preenchidas, Possibilidades_L) :-
  findall(Poss, (combinacoes(Total, Posicoes_Linha, Combinacao),
    valida_poss(Puz, Ja_Preenchidas, Combinacao, Poss)), Unsorted_Lista_Poss),
  sort(Unsorted_Lista_Poss, Possibilidades_L).

%-----------------------------------Auxiliares----------------------------------%

% valida_poss/4
% valida_poss(Puz, Ja_Preenchidas, Combinacao, Poss) dado o puzzle Puz e a lista de
%   posicoes ja preenchidas Ja_Preenchidas, afirma que a possibilidade Poss para preencher
%   uma determinada linha e valida, tendo essa possibilidade partido da Combinacao
%   de posicoes a preencher nessa determinada linha
valida_poss(_, _, [], []).
valida_poss(Puz, Ja_Preenchidas, Combinacao, Poss) :-
  nth1(1, Combinacao, Pos),
  linha(Pos, Linha),
  constroi_poss(Puz, Combinacao, [], Poss),
  ja_preenchidas_linha(Linha, Ja_Preenchidas, Ja_Preenchidas_L),
  ja_preenchidas_linha_contidas_poss(Ja_Preenchidas_L, Poss),
  respeita_total_linha(Combinacao, Linha, Poss),
  nao_altera_linhas_anteriores(Poss, Linha, Ja_Preenchidas),
  dim(Puz, Dim),
  verifica_parcial(Puz, Ja_Preenchidas, Dim, Poss).

% constroi_poss/4
% constroi_poss(Puz, Combinacao, Poss) dado o puzzle Puz, afirma que Poss e a lista de
%   posicoes a preencher para preencher as posicoes da Combinacao.
constroi_poss(Puz, Combinacao, Poss) :-
  constroi_poss(Puz, Combinacao, [], Poss).
constroi_poss(_, [], Unsorted_Poss_Total, Poss_Total) :-
  sort(Unsorted_Poss_Total, Poss_Total).
constroi_poss(Puz, [Head_Comb | Tail_Comb], Poss_Parcial, Poss_Total) :-
  propaga(Puz, Head_Comb, Posicoes),
  append(Poss_Parcial, Posicoes, New_Poss_Parcial),
  constroi_poss(Puz, Tail_Comb, New_Poss_Parcial, Poss_Total).

% ja_preenchidas_linha/3
% ja_preenchidas_linha(Linha, Ja_Preenchidas, Ja_Preenchidas_L) dada a linha Linha e
%   a lista de posicoes Ja_Preenchidas, afirma que a lista Ja_Preenchidas_L sao as posicoes
%   ja preenchidas na linha Linha.
ja_preenchidas_linha(Linha, Ja_Preenchidas, Ja_Preenchidas_L) :-
  ja_preenchidas_linha(Linha, Ja_Preenchidas, [], Ja_Preenchidas_L).
ja_preenchidas_linha(_, [], Ja_Preenchidas_L, Ja_Preenchidas_L).
ja_preenchidas_linha(Linha, [Head_Ja_P | Tail_Ja_P], Old_Ja_Preenchidas_L, Ja_Preenchidas_L) :-
  linha(Head_Ja_P, Linha_Head),
  Linha \== Linha_Head,
  ja_preenchidas_linha(Linha, Tail_Ja_P, Old_Ja_Preenchidas_L, Ja_Preenchidas_L).
ja_preenchidas_linha(Linha, [Head_Ja_P | Tail_Ja_P], Old_Ja_Preenchidas_L, Ja_Preenchidas_L) :-
  linha(Head_Ja_P, Linha_Head),
  Linha =:= Linha_Head,
  append(Old_Ja_Preenchidas_L, [Head_Ja_P], New_Ja_Preenchidas_L),
  ja_preenchidas_linha(Linha, Tail_Ja_P, New_Ja_Preenchidas_L, Ja_Preenchidas_L).

% ja_preenchidas_linha_contidas_poss/2
% ja_preenchidas_linha_contidas_poss(Ja_Preenchidas_L, Poss) afirma que a lista
%   Ja_Preenchidas_L esta contida na lista Poss
ja_preenchidas_linha_contidas_poss([], _).
ja_preenchidas_linha_contidas_poss([Head_Ja_P_L | Tail_Ja_P_L], Poss) :-
  member(Head_Ja_P_L, Poss),
  ja_preenchidas_linha_contidas_poss(Tail_Ja_P_L, Poss).

% respeita_total_linha/3
% respeita_total_linha(Combinacao, Linha, Poss) afirma que todas as posicoes da lista
%   Poss que sao da linha Linha, estao contidas na lista Combinacao
respeita_total_linha(_, _, []).
respeita_total_linha(Combinacao, Linha, [Head_Poss | Tail_Poss]) :-
  linha(Head_Poss, Linha_Pos),
  Linha \== Linha_Pos,
  respeita_total_linha(Combinacao, Linha, Tail_Poss).
respeita_total_linha(Combinacao, Linha, [Head_Poss | Tail_Poss]) :-
  linha(Head_Poss, Linha_Pos),
  Linha =:= Linha_Pos,
  member(Head_Poss, Combinacao),
  respeita_total_linha(Combinacao, Linha, Tail_Poss).

%-------------------------------------------------------------------------------%
%                                    RESOLVE                                    %
%-------------------------------------------------------------------------------%

% resolve/2
% resolve(Puz, Solucao) afirma que a lista de posicoes Solucao e solucao para o puzzle Puz
resolve(Puz, Solucao) :-
  dim(Puz, Dim),
  get_solucao(Puz, Dim, Solucao).

%-----------------------------------Auxiliares----------------------------------%

% get_solucao/3
% get_solucao(Puz, Dim, Solucao) afirma que a lista de posicoes Solucao e solucao
%   para o puzzle Puz, de dimensao Dim
get_solucao(Puz, Dim, Solucao) :-
  get_solucao(Puz, 1, Dim, Solucao).
get_solucao(Puz, Linha, Dim, Solucao) :-
  get_solucao(Puz, Linha, Dim, [], Solucao).
get_solucao(Puz, Dim, Dim, Ja_Preenchidas, Solucao) :-
  posicoes_linha(Dim, Dim, Posicoes_Linha),
  !, % posicoes da linha nao mudam
  nth1(2, Puz, Max_Linhas),
  nth1(Dim, Max_Linhas, Total),
  possibilidades_linha(Puz, Posicoes_Linha, Total, Ja_Preenchidas, Possibilidades_L),
  member(Legit_Poss, Possibilidades_L),
  append(Ja_Preenchidas, Legit_Poss, Unsorted_Solucao),
  sort(Unsorted_Solucao, Solucao).
get_solucao(Puz, Linha, Dim, Ja_Preenchidas, Solucao) :-
  posicoes_linha(Linha, Dim, Posicoes_Linha),
  !, % posicoes da linha nao mudam
  nth1(2, Puz, Max_Linhas),
  nth1(Linha, Max_Linhas, Total),
  possibilidades_linha(Puz, Posicoes_Linha, Total, Ja_Preenchidas, Possibilidades_L),
  member(Legit_Poss, Possibilidades_L),
  Linha_N is Linha + 1,
  append(Ja_Preenchidas, Legit_Poss, New_Ja_Preenchidas),
  get_solucao(Puz, Linha_N, Dim, New_Ja_Preenchidas, Solucao).

% posicoes_linha/3
% posicoes_linha(Linha, Dim, Posicoes_Linha) afirma que a lista de posicoes Posicoes_Linha
%   e a lista de posicoes da linha Linha com dimensao Dim
posicoes_linha(Linha, Dim, Posicoes_Linha) :-
  posicoes_linha(Linha, Dim, 1, [], Posicoes_Linha).
posicoes_linha(Linha, Dim, Dim, Ac_Posicoes, Posicoes_Linha) :-
  append(Ac_Posicoes, [(Linha, Dim)], Posicoes_Linha).
posicoes_linha(Linha, Dim, Coluna, Ac_Posicoes, Posicoes_Linha) :-
  append(Ac_Posicoes, [(Linha, Coluna)], Ac_Posicoes_N),
  Coluna_N is Coluna + 1,
  posicoes_linha(Linha, Dim, Coluna_N, Ac_Posicoes_N, Posicoes_Linha).
