 m o d u l e   h u r t . s t d i o . i n p u t s t r e a m ; 
 
 i m p o r t   h u r t . s t d i o . f i l e ; 
 i m p o r t   h u r t . s t d i o . i o f l a g s ; 
 
 i m p o r t   h u r t . c o n v . c o n v ; 
 i m p o r t   h u r t . c o n t a i n e r . v e c t o r ; 
 
 i m p o r t   s t d . s t d i o ; 
 
 c l a s s   I n p u t S t r e a m   { 
 	 i n t   f d ; 
 	 e n u m   B O M   { 
 	 	 U T F 8 , 
 	 	 U T F 1 6 , 
 	 	 U T F 3 2 
 	 } 
 	 
 	 B O M   e n c o d i n g ; 
 	 V e c t o r ! ( u b y t e )   b u f ; 
 
 	 t h i s ( s t r i n g   f i l e N a m e )   { 
 	 	 t h i s . f d   =   o p e n ( f i l e N a m e ,   F i l e F l a g s . O _ R D O N L Y ,   0 ) ; 
 	 	 i n t   e r r o r   =   g e t E r r n o ( ) ; 
 	 	 a s s e r t ( e r r o r   = =   0 ,   e r r n o T o S t r i n g ( e r r o r ) ) ; 
 	 	 a c q u i r e B O M ( ) ; 
 	 } 
 
 	 v o i d   a c q u i r e B O M ( )   { 
 	 	 s e e k ( t h i s . f d ,   0 , S e e k T y p e . S E E K _ S E T ) ; 	 
 	 	 u b y t e [ ]   r e a d b   =   n e w   u b y t e [ 4 ] ; 
 	 	 l o n g   r c n t   =   r e a d ( f d ,   c a s t ( b y t e [ ] ) r e a d b ,   4 ) ; 
 	 	 i f ( r e a d b [ 0 ]   = =   0 x E F   & &   r e a d b [ 1 ]   = =   0 x B B   & &   r e a d b [ 2 ]   = =   0 x B F )   { 
 	 	 	 t h i s . e n c o d i n g   =   B O M . U T F 8 ; 
 	 	 }   e l s e   i f ( ( r e a d b [ 0 ]   = =   2 5 5   & &   r e a d b [ 1 ]   = =   2 5 4   & &   r e a d b [ 2 ]   = =   0   & &   r e a d b [ 3 ]   = =   0 ) 
 	 	 	 	 | | ( r e a d b [ 3 ]   = =   0 x F F   & &   r e a d b [ 2 ]   = =   0 x F E   & &   r e a d b [ 1 ]   = =   0   & &   r e a d b [ 1 ]   = =   0 ) )   { 
 	 	 	 t h i s . e n c o d i n g   =   B O M . U T F 3 2 ; 
 	 	 }   e l s e   i f ( ( r e a d b [ 0 ]   = =   0 x F E   & &   r e a d b [ 1 ]   = =   0 x F F ) 
 	 	 	 	 | |   ( r e a d b [ 1 ]   = =   0 x F E   & &   r e a d b [ 0 ]   = =   0 x F F ) ) { 
 	 	 	 t h i s . e n c o d i n g   =   B O M . U T F 1 6 ; 
 	 	 }   e l s e   { 
 	 	 	 t h i s . e n c o d i n g   =   B O M . U T F 8 ; 
 	 	 } 
 	 } 
 
 	 s t r i n g   g e t B O M ( )   c o n s t   { 
 	 	 i f ( t h i s . e n c o d i n g   = =   B O M . U T F 1 6 )   { 
 	 	 	 r e t u r n   " U T F 1 6 " ; 
 	 	 }   e l s e   i f ( t h i s . e n c o d i n g   = =   B O M . U T F 3 2 )   { 
 	 	 	 r e t u r n   " U T F 3 2 " ; 
 	 	 }   e l s e   { 
 	 	 	 r e t u r n   " U T F 8 " ; 
 	 	 } 
 	 } 
 
 	 s t r i n g   r e a d L i n e ( )   { 
 	 	 u b y t e [ 1 2 8 ]   t m p ; 
 	 	 l o n g   r c n t   =   r e a d ( f d ,   c a s t ( b y t e [ ] ) r e a d ,   1 2 8 ) 	 
 	 } 
 
 	 ~ t h i s ( )   { 
 	 	 t h i s . c l o s e ( ) ; 
 	 } 
 
 	 v o i d   c l o s e ( )   { 
 	 	 h u r t . s t d i o . f i l e . c l o s e ( f d ) ; 
 	 } 
 } 
