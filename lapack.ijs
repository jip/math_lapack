NB. init

require 'numeric'

coclass 'jlapack'
NB. lapack definitions

path=: jpath '~addons/math/lapack/'

3 : 0''
if. UNAME-:'Linux' do.
  dll=: 'liblapack.so.3 '
  JLAPACK=: 'F'
elseif. UNAME-:'Darwin' do.
  JLAPACK=: 'J'
  dll=: '/System/Library/Frameworks/vecLib.framework/vecLib '
elseif. UNAME-:'Win' do.
  if. IF64 do.
    if. fexist path,'jlapack64.dll' do.
      dll=: '"',path,'jlapack64.dll" '
      JLAPACK=: 'J'
    else.
      dll=: 'liblapack.dll '
      JLAPACK=: 'F'
    end.
  else.
    dll=: '"',path,'jlapack.dll" '
    JLAPACK=: 'J'
  end.
elseif. UNAME-:'Android' do.
  JLAPACK=: 'J'
  dll=: '"',(jpath'~bin/'),'liblapack.so" '
  if. 0=fexist dltb dll -. '"' do.
    smoutput 'lapack error: please run install_jlapack_'''' to install liblapack.so'
  end.
elseif. do.
  'platform not supported' 13!:8[10
end.
''
)

NB. =========================================================
call=: 4 : 0
if. 'F'=JLAPACK do.
  x=. dll,x,'_ + n ',(+:#y)$' *'
  r=. x cd LASTIN=: y
  LASTOUT=: }.r
elseif. 'J'=JLAPACK do.
  x=. dll,x,'_ + i ',(+:#y)$' *'
  r=. x cd LASTIN=: y
  if. > {. r do.
    error x;'lapack dll return code: ',": > {. r
  else.
    LASTOUT=: }.r
  end.
end.
)

NB. =========================================================
docs=: 3 : 0
NB. if. 0>4!:0 <'dirs' do. load 'dir' end.
NB. dirs jpathsep path,'doc/*.lap'
{.("1) 1!:0 jpathsep path,'doc/*.lap'
)

NB. =========================================================
need=: 3 : 0
require (<path) ,each (;:y) ,each <'.ijs'
)

NB. =========================================================
routines=: 3 : 0
NB. if. 0>4!:0 <'dirs' do. load 'dir' end.
NB. dirs jpathsep path,'*.ijs'
{.("1) 1!:0 jpathsep path,'*.ijs'
)

install=: 3 : 0
if. -. UNAME-:'Android' do. return. end.
armv6=. 1 e.'ARMv6' E. 2!:0 'cat /proc/cpuinfo'
require 'pacman'
'rc p'=. httpget_jpacman_ 'http://www.jsoftware.com/download/', z=. 'liblapack-armv',(armv6{'75'),'.so'
if. rc do.
  smoutput 'unable to download: ',z return.
end.
(<jpath'~bin/liblapack.so') 1!:2~ 1!:1 <p
1!:55 ::0: <p
smoutput 'done'
EMPTY
)

NB. lapack utils
NB.
NB. lapzero etc.
NB.
NB. cutarg        cut argument list
NB. error         display message and signal error
NB. extijs        ensure script has ijs extension
NB. z2d           convert complex to float datatype if zero imagine part
NB.
NB. matchclean    if clean x-y is all 0
NB.
NB. diagmat       rectangular diagonal matrix
NB. idmat         rectangular identity matrix with shifted diagonal
NB. ltmat         lower triangular (trapezoidal) matrix
NB. utmat         upper triangular (trapezoidal) matrix
NB.
NB. ltri          return only lower triangular (trapezoidal) matrix
NB. utri          return only upper triangular (trapezoidal) matrix
NB. sltri         return only strictly lower triangular (trapezoidal) matrix
NB. sutri         return only strictly upper triangular (trapezoidal) matrix
NB.
NB. cxpair        reconstruct complex columns
NB. xtoken        exclude tokens with indices in x from list y
NB. invperm       inverse permutation of x by pivot indices
NB.               from y
NB. makepermat    generate inverse permutation matrix P from
NB.               pivot indices y
NB. fixint        fix 64-bit integer

cd=: 15!:0

izero=: 23-23
ione=: 23-22
dzero=: 1.1-1.1
done=: 2.1-1.1
zzero=: 1j1-1j1
zone=: 2j1-1j1

cutarg=: <;._1 @ (';'&,)
extijs=: , ((0: < #) *. [: -. '.'"_ e. ]) # '.ijs'"_
z2d=: [ ^: (-. @ -:) (9 & o.)

mp=: +/ . *

NB. =========================================================
matchclean=: 0: *./ . = clean @ , @: -

NB. =========================================================
NB. diagmat   rectangular diagonal matrix with y on diagonal
NB. x=rows-columns , x=0 is default
NB. e.g.
NB.    diagmat 3 5 7
NB. 3 0 0
NB. 0 5 0
NB. 0 0 7
NB.    1 diagmat 3 5 7
NB. 3 0 0
NB. 0 5 0
NB. 0 0 7
NB. 0 0 0
NB.    _1 diagmat 3 5 7
NB. 3 0 0 0
NB. 0 5 0 0
NB. 0 0 7 0

diagmat=: (0 $: ]) :(((0 (>. , -@<.) [) + #@]) {. (* =@i.@#)@])

NB. =========================================================
NB. idmat   rectangular identity matrix with shifted diagonal
NB. e.g.
NB.    idmat 3
NB. 1 0 0
NB. 0 1 0
NB. 0 0 1
NB.    idmat 3 4
NB. 1 0 0 0
NB. 0 1 0 0
NB. 0 0 1 0
NB.    1 idmat 3 4
NB. 0 1 0 0
NB. 0 0 1 0
NB. 0 0 0 1

idmat=: (0 $: ]) :(= ({. -~/&i. {:)@])

NB. =========================================================
NB. ltmat   lower triangular (trapezoidal) boolean matrix
NB. e.g.
NB.    ltmat 3
NB. 1 0 0
NB. 1 1 0
NB. 1 1 1
NB.    ltmat 3 5
NB. 1 0 0 0 0
NB. 1 1 0 0 0
NB. 1 1 1 0 0
NB.    1 ltmat 3 5
NB. 1 1 0 0 0
NB. 1 1 1 0 0
NB. 1 1 1 1 0

ltmat=: (0 $: ]) :(>: ({. -~/&i. {:)@])

NB. =========================================================
NB. utmat   upper triangular (trapezoidal) boolean matrix
NB. e.g.
NB.    utmat 3
NB. 1 1 1
NB. 0 1 1
NB. 0 0 1
NB.    utmat 3 5
NB. 1 1 1 1 1
NB. 0 1 1 1 1
NB. 0 0 1 1 1
NB.    1 utmat 3 5
NB. 0 1 1 1 1
NB. 0 0 1 1 1
NB. 0 0 0 1 1

utmat=: (0 $: ]) :(<: ({. -~/&i. {:)@])

NB. =========================================================
NB. ltri   return only lower triangular (trapezoidal) matrix
NB. e.g.
NB.   ltri 3 5 $ 2
NB. 2 0 0 0 0
NB. 2 2 0 0 0
NB. 2 2 2 0 0
NB.    1 ltri 3 5 $ 2
NB. 2 2 0 0 0
NB. 2 2 2 0 0
NB. 2 2 2 2 0

ltri=: (0 $: ]) : (] * (>: ({. -~/&i. {:)@$@]))

NB. =========================================================
NB. utri   return only upper triangular (trapezoidal) matrix
NB. e.g.
NB.    utri 3 5 $ 2
NB. 2 2 2 2 2
NB. 0 2 2 2 2
NB. 0 0 2 2 2
NB.    1 utri 3 5 $ 2
NB. 0 2 2 2 2
NB. 0 0 2 2 2
NB. 0 0 0 2 2

utri=: (0 $: ]) : (] * (<: ({. -~/&i. {:)@$@]))

NB. =========================================================
NB. sltri   return only strictly lower triangular (trapezoidal) matrix
NB. e.g.
NB.    sltri 3 5 $ 2
NB. 0 0 0 0 0
NB. 2 0 0 0 0
NB. 2 2 0 0 0
NB.    1 sltri 3 5 $ 2
NB. 2 0 0 0 0
NB. 2 2 0 0 0
NB. 2 2 2 0 0

sltri=: (0 $: ]) : (] * (> ({. -~/&i. {:)@$@]))

NB. =========================================================
NB. sutri   return only strictly upper triangular (trapezoidal) matrix
NB. e.g.
NB.    sutri 3 5 $ 2
NB. 0 2 2 2 2
NB. 0 0 2 2 2
NB. 0 0 0 2 2
NB.    1 sutri 3 5 $ 2
NB. 0 0 2 2 2
NB. 0 0 0 2 2
NB. 0 0 0 0 2

sutri=: (0 $: ]) : (] * (< ({. -~/&i. {:)@$@]))

NB. =========================================================
NB. cxpair - reconstruct complex columns

cxpair=: 4 : 0
'i j'=: |: _2 [\ x
r=. i {"1 y
z=. j. j {"1 y
n=. (r+z) ,. r-z
n (i,j)}"1 y
)

NB. =========================================================
NB. xtoken - exclude tokens with indices in x from list y
xtoken=: }:@;@(< ^:3@[ { <;.2@(';' ,~ ]))

NB. =========================================================
NB. pivot indices utilities
NB.
NB. pivot indices come from DGETRF, ZGETRF etc. as IPIV;
NB. IPIV(i) and i are 1-based numbers of rows, mutually
NB. interchanged in table
NB.
NB. invperm    - inverse permutation of x by pivot indices
NB.              from y
NB. makepermat - generate inverse permutation matrix P from
NB.              pivot indices y

NB. ipiv2scrp=: ((}: ^: ({. -: {:)) &. >)@(<"1)@(i.@# ,. <:)  NB. pivot indices to standard cycle representation of the permutation
ipiv2scrp=: <"1@(#~ ~:/"1)@(i.@# ,. <:)  NB. pivot indices to standard cycle representation of the permutation
invperm=: C.~ ipiv2scrp
makepermat=: C. @ ipiv2scrp =/ i. @ #

NB. =========================================================
NB. error - display message and signal error
error=: 3 : 0
sminfo y
error=. 13!:8@1:
error ''
)

NB. =========================================================
NB. fixint - fix 64-bit integer
fixint=: 3 : 0
if. IF64*.IFWIN+.JLAPACK='F' do.
  s=. $y
  if. 2>*/s do.
    (17 b.)&16bffffffff y
  else.
    s$ _2 ic (*/4,s){. (3 ic ,y)
  end.
else.
  y
end.
)
NB. lapack validation
NB.
NB. validation routines that check argument is a matrix:
NB.    vmatrix
NB.    vhermitian
NB.    vorthogonal
NB.    vsquare
NB.    vsymposdef
NB.
NB. validation routines that check argument is either
NB. a matrix or vector:
NB.    vmatrixorvector

iscomplex=: -. @ (-: +)
isvector=: 1: = #@$
ismatrix=: 2: = #@$
ismatrixorvector=: 1 2 e.~ #@$
isreal=: -: +
issquare=: =/ @ $
ishermitian=: -: +@|:

NB. =========================================================
isorthogonal=: 3 : 0
q=. y mp |: y
*./ 0 = clean ,q - idmat $q
)

NB. =========================================================
issymposdef=: 3 : 0
if. 0==/$y do. 0 return. end.
y-:|:y
)

NB. =========================================================
f=. 2 : 'm&(13!:8)@(#&12)@(0 e. v)'

vmatrix=: 'argument should be a matrix' f ismatrix
vmatrixorvector=: 'argument should be either a matrix or vector' f ismatrixorvector
vhermitian=: 'argument should be a hermitian matrix' f ishermitian [ vmatrix
vorthogonal=: 'argument should be an orthogonal matrix' f isorthogonal [ vmatrix
vsquare=: 'argument should be a square matrix' f issquare [ vmatrix
vsymposdef=: 'argument should be a symmetric positive-definite matrix' f issymposdef [ vmatrix
