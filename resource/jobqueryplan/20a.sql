SELECT MIN(t.title) AS complete_downey_ironman_movie
FROM complete_cast AS cc,
     comp_cast_type AS cct1,
     comp_cast_type AS cct2,
     char_name AS chn,
     cast_info AS ci,
     keyword AS k,
     kind_type AS kt,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE cct1.kind = 'cast'
  AND cct2.kind LIKE '%complete%'
  AND chn.name NOT LIKE '%Sherlock%'
  AND (chn.name LIKE '%Tony%Stark%'
       OR chn.name LIKE '%Iron%Man%')
  AND k.keyword IN ('superhero',
                    'sequel',
                    'second-part',
                    'marvel-comics',
                    'based-on-comic',
                    'tv-special',
                    'fight',
                    'violence')
  AND kt.kind = 'movie'
  AND t.production_year > 1950
  AND kt.id = t.kind_id
  AND t.id = mk.movie_id
  AND t.id = ci.movie_id
  AND t.id = cc.movie_id
  AND mk.movie_id = ci.movie_id
  AND mk.movie_id = cc.movie_id
  AND ci.movie_id = cc.movie_id
  AND chn.id = ci.person_role_id
  AND n.id = ci.person_id
  AND k.id = mk.keyword_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id;



Aggregate  (cost=12395.49..12395.50 rows=1 width=32)
  ->  Nested Loop  (cost=9.06..12395.49 rows=1 width=17)
        ->  Nested Loop  (cost=8.63..12395.03 rows=1 width=21)
              ->  Nested Loop  (cost=8.20..12389.51 rows=12 width=25)
                    Join Filter: (t.id = ci.movie_id)
                    ->  Nested Loop  (cost=7.63..12383.46 rows=3 width=29)
                          Join Filter: (t.kind_id = kt.id)
                          ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=4)
                                Filter: ((kind)::text = 'movie'::text)
                          ->  Nested Loop  (cost=7.63..12382.13 rows=20 width=33)
                                ->  Nested Loop  (cost=7.20..12371.39 rows=22 width=8)
                                      Join Filter: (cc.status_id = cct2.id)
                                      ->  Seq Scan on comp_cast_type cct2  (cost=0.00..1.05 rows=1 width=4)
                                            Filter: ((kind)::text ~~ '%complete%'::text)
                                      ->  Nested Loop  (cost=7.20..12369.22 rows=90 width=12)
                                            Join Filter: (cc.subject_id = cct1.id)
                                            ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
                                                  Filter: ((kind)::text = 'cast'::text)
                                            ->  Nested Loop  (cost=7.20..12363.68 rows=359 width=16)
                                                  ->  Nested Loop  (cost=6.78..12235.17 rows=270 width=4)
                                                        ->  Seq Scan on keyword k  (cost=0.00..3632.40 rows=8 width=4)
                                                              Filter: ((keyword)::text = ANY ('{superhero,sequel,second-part,marvel-comics,based-on-comic,tv-special,fight,violence}'::text[]))
                                                        ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1072.32 rows=303 width=8)
                                                              Recheck Cond: (keyword_id = k.id)
                                                              ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                    Index Cond: (keyword_id = k.id)
                                                  ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..0.46 rows=2 width=12)
                                                        Index Cond: (movie_id = mk.movie_id)
                                ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=25)
                                      Index Cond: (id = mk.movie_id)
                                      Filter: (production_year > 1950)
                    ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.54 rows=38 width=12)
                          Index Cond: (movie_id = mk.movie_id)
              ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.46 rows=1 width=4)
                    Index Cond: (id = ci.person_role_id)
                    Filter: (((name)::text !~~ '%Sherlock%'::text) AND (((name)::text ~~ '%Tony%Stark%'::text) OR ((name)::text ~~ '%Iron%Man%'::text)))
        ->  Index Only Scan using name_pkey on name n  (cost=0.43..0.45 rows=1 width=4)
              Index Cond: (id = ci.person_id)
