SELECT MIN(t.title) AS movie_title
FROM keyword AS k,
     movie_info AS mi,
     movie_keyword AS mk,
     title AS t
WHERE k.keyword LIKE '%sequel%'
  AND mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Denish',
                  'Norwegian',
                  'German')
  AND t.production_year > 2005
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND mk.movie_id = mi.movie_id
  AND k.id = mk.keyword_id;



Aggregate  (cost=16768.85..16768.86 rows=1 width=32)
  ->  Nested Loop  (cost=7.65..16768.68 rows=68 width=17)
        Join Filter: (t.id = mi.movie_id)
        ->  Nested Loop  (cost=7.21..16453.87 rows=174 width=25)
              ->  Nested Loop  (cost=6.78..16240.14 rows=438 width=4)
                    ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=13 width=4)
                          Filter: ((keyword)::text ~~ '%sequel%'::text)
                    ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1044.20 rows=303 width=8)
                          Recheck Cond: (keyword_id = k.id)
                          ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                Index Cond: (keyword_id = k.id)
              ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21)
                    Index Cond: (id = mk.movie_id)
                    Filter: (production_year > 2005)
        ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.80 rows=1 width=4)
              Index Cond: (movie_id = mk.movie_id)
              Filter: ((info)::text = ANY ('{Sweden,Norway,Germany,Denmark,Swedish,Denish,Norwegian,German}'::text[]))
