SELECT MIN(k.keyword) AS movie_keyword,
       MIN(n.name) AS actor_name,
       MIN(t.title) AS marvel_movie
FROM cast_info AS ci,
     keyword AS k,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE k.keyword = 'marvel-cinematic-universe'
  AND n.name LIKE '%Downey%Robert%'
  AND t.production_year > 2000
  AND k.id = mk.keyword_id
  AND t.id = mk.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mk.movie_id
  AND n.id = ci.person_id;



Aggregate  (cost=4119.66..4119.67 rows=1 width=96)
  ->  Nested Loop  (cost=8.21..4119.65 rows=1 width=48)
        ->  Nested Loop  (cost=7.78..3799.93 rows=699 width=37)
              Join Filter: (t.id = ci.movie_id)
              ->  Nested Loop  (cost=7.21..3763.63 rows=18 width=41)
                    ->  Nested Loop  (cost=6.78..3747.04 rows=34 width=20)
                          ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=1 width=20)
                                Filter: ((keyword)::text = 'marvel-cinematic-universe'::text)
                          ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1117.89 rows=303 width=8)
                                Recheck Cond: (keyword_id = k.id)
                                ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                      Index Cond: (keyword_id = k.id)
                    ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21)
                          Index Cond: (id = mk.movie_id)
                          Filter: (production_year > 2000)
              ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.54 rows=38 width=8)
                    Index Cond: (movie_id = mk.movie_id)
        ->  Index Scan using name_pkey on name n  (cost=0.43..0.46 rows=1 width=19)
              Index Cond: (id = ci.person_id)
              Filter: ((name)::text ~~ '%Downey%Robert%'::text)
