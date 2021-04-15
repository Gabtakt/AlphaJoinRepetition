SELECT MIN(chn.name) AS character_name,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS complete_hero_movie
FROM complete_cast AS cc,
     comp_cast_type AS cct1,
     comp_cast_type AS cct2,
     char_name AS chn,
     cast_info AS ci,
     info_type AS it,
     keyword AS k,
     kind_type AS kt,
     movie_info_idx AS mi_idx,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE cct1.kind = 'cast'
  AND cct2.kind LIKE '%complete%'
  AND chn.name IS NOT NULL
  AND (chn.name LIKE '%man%'
       OR chn.name LIKE '%Man%')
  AND it.info = 'rating'
  AND k.keyword IN ('superhero',
                    'marvel-comics',
                    'based-on-comic',
                    'tv-special',
                    'fight',
                    'violence',
                    'magnet',
                    'web',
                    'claw',
                    'laser')
  AND kt.kind = 'movie'
  AND t.production_year > 2000
  AND kt.id = t.kind_id
  AND t.id = mk.movie_id
  AND t.id = ci.movie_id
  AND t.id = cc.movie_id
  AND t.id = mi_idx.movie_id
  AND mk.movie_id = ci.movie_id
  AND mk.movie_id = cc.movie_id
  AND mk.movie_id = mi_idx.movie_id
  AND ci.movie_id = cc.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND cc.movie_id = mi_idx.movie_id
  AND chn.id = ci.person_role_id
  AND n.id = ci.person_id
  AND k.id = mk.keyword_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id
  AND it.id = mi_idx.info_type_id;



Aggregate  (cost=14816.04..14816.05 rows=1 width=96)
  ->  Nested Loop  (cost=9.48..14816.03 rows=1 width=38)
        Join Filter: (it.id = mi_idx.info_type_id)
        ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
              Filter: ((info)::text = 'rating'::text)
        ->  Nested Loop  (cost=9.48..14813.61 rows=1 width=42)
              Join Filter: (t.id = mi_idx.movie_id)
              ->  Nested Loop  (cost=9.06..14813.09 rows=1 width=49)
                    ->  Nested Loop  (cost=8.63..14806.68 rows=14 width=37)
                          ->  Nested Loop  (cost=8.20..14800.31 rows=14 width=41)
                                Join Filter: (t.id = ci.movie_id)
                                ->  Nested Loop  (cost=7.63..14798.30 rows=1 width=29)
                                      Join Filter: (cc.status_id = cct2.id)
                                      ->  Nested Loop  (cost=7.63..14797.23 rows=1 width=33)
                                            Join Filter: (cct1.id = cc.subject_id)
                                            ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
                                                  Filter: ((kind)::text = 'cast'::text)
                                            ->  Nested Loop  (cost=7.63..14796.17 rows=1 width=37)
                                                  ->  Nested Loop  (cost=7.21..14783.74 rows=26 width=25)
                                                        Join Filter: (kt.id = t.kind_id)
                                                        ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=4)
                                                              Filter: ((kind)::text = 'movie'::text)
                                                        ->  Nested Loop  (cost=7.21..14780.36 rows=183 width=29)
                                                              ->  Nested Loop  (cost=6.78..14615.92 rows=337 width=4)
                                                                    ->  Seq Scan on keyword k  (cost=0.00..3967.82 rows=10 width=4)
                                                                          Filter: ((keyword)::text = ANY ('{superhero,marvel-comics,based-on-comic,tv-special,fight,violence,magnet,web,claw,laser}'::text[]))
                                                                    ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1061.78 rows=303 width=8)
                                                                          Recheck Cond: (keyword_id = k.id)
                                                                          ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                                Index Cond: (keyword_id = k.id)
                                                              ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=25)
                                                                    Index Cond: (id = mk.movie_id)
                                                                    Filter: (production_year > 2000)
                                                  ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..0.46 rows=2 width=12)
                                                        Index Cond: (movie_id = t.id)
                                      ->  Seq Scan on comp_cast_type cct2  (cost=0.00..1.05 rows=1 width=4)
                                            Filter: ((kind)::text ~~ '%complete%'::text)
                                ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.54 rows=38 width=12)
                                      Index Cond: (movie_id = mk.movie_id)
                          ->  Index Only Scan using name_pkey on name n  (cost=0.43..0.45 rows=1 width=4)
                                Index Cond: (id = ci.person_id)
                    ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.46 rows=1 width=20)
                          Index Cond: (id = ci.person_role_id)
                          Filter: ((name IS NOT NULL) AND (((name)::text ~~ '%man%'::text) OR ((name)::text ~~ '%Man%'::text)))
              ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.48 rows=3 width=13)
                    Index Cond: (movie_id = ci.movie_id)
