SELECT MIN(k.keyword) AS movie_keyword,
       MIN(n.name) AS actor_name,
       MIN(t.title) AS hero_movie
FROM cast_info AS ci,
     keyword AS k,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE k.keyword IN ('superhero',
                    'sequel',
                    'second-part',
                    'marvel-comics',
                    'based-on-comic',
                    'tv-special',
                    'fight',
                    'violence')
  AND n.name LIKE '%Downey%Robert%'
  AND t.production_year > 2014
  AND k.id = mk.keyword_id
  AND t.id = mk.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mk.movie_id
  AND n.id = ci.person_id;



Aggregate  (cost=12369.40..12369.41 rows=1 width=96)
  ->  Nested Loop  (cost=8.21..12369.39 rows=1 width=48)
        ->  Nested Loop  (cost=7.78..12368.94 rows=1 width=37)
              Join Filter: (t.id = ci.movie_id)
              ->  Nested Loop  (cost=7.21..12366.92 rows=1 width=41)
                    ->  Nested Loop  (cost=6.78..12235.17 rows=270 width=20)
                          ->  Seq Scan on keyword k  (cost=0.00..3632.40 rows=8 width=20)
                                Filter: ((keyword)::text = ANY ('{superhero,sequel,second-part,marvel-comics,based-on-comic,tv-special,fight,violence}'::text[]))
                          ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1072.32 rows=303 width=8)
                                Recheck Cond: (keyword_id = k.id)
                                ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                      Index Cond: (keyword_id = k.id)
                    ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21)
                          Index Cond: (id = mk.movie_id)
                          Filter: (production_year > 2014)
              ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.54 rows=38 width=8)
                    Index Cond: (movie_id = mk.movie_id)
        ->  Index Scan using name_pkey on name n  (cost=0.43..0.46 rows=1 width=19)
              Index Cond: (id = ci.person_id)
              Filter: ((name)::text ~~ '%Downey%Robert%'::text)
