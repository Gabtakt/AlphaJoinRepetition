SELECT MIN(mi_idx.info) AS rating,
       MIN(t.title) AS movie_title
FROM info_type AS it,
     keyword AS k,
     movie_info_idx AS mi_idx,
     movie_keyword AS mk,
     title AS t
WHERE it.info = 'rating'
  AND k.keyword LIKE '%sequel%'
  AND mi_idx.info > '5.0'
  AND t.production_year > 2005
  AND t.id = mi_idx.movie_id
  AND t.id = mk.movie_id
  AND mk.movie_id = mi_idx.movie_id
  AND k.id = mk.keyword_id
  AND it.id = mi_idx.info_type_id;



Aggregate  (cost=16474.13..16474.14 rows=1 width=64)
  ->  Nested Loop  (cost=7.64..16474.12 rows=2 width=22)
        Join Filter: (mi_idx.movie_id = t.id)
        ->  Nested Loop  (cost=7.21..16471.61 rows=5 width=13)
              Join Filter: (mi_idx.info_type_id = it.id)
              ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                    Filter: ((info)::text = 'rating'::text)
              ->  Nested Loop  (cost=7.21..16462.59 rows=529 width=17)
                    ->  Nested Loop  (cost=6.78..16240.14 rows=438 width=4)
                          ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=13 width=4)
                                Filter: ((keyword)::text ~~ '%sequel%'::text)
                          ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1044.20 rows=303 width=8)
                                Recheck Cond: (keyword_id = k.id)
                                ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                      Index Cond: (keyword_id = k.id)
                    ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.50 rows=1 width=13)
                          Index Cond: (movie_id = mk.movie_id)
                          Filter: ((info)::text > '5.0'::text)
        ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21)
              Index Cond: (id = mk.movie_id)
              Filter: (production_year > 2005)
