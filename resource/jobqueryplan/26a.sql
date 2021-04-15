SELECT MIN(chn.name) AS character_name,
       MIN(mi_idx.info) AS rating,
       MIN(n.name) AS playing_actor,
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
  AND mi_idx.info > '7.0'
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



Aggregate  (cost=11365.77..11365.78 rows=1 width=128)
  ->  Nested Loop  (cost=5.26..11365.76 rows=1 width=53)
        Join Filter: (kt.id = t.kind_id)
        ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=4)
              Filter: ((kind)::text = 'movie'::text)
        ->  Nested Loop  (cost=5.26..11364.66 rows=1 width=57)
              Join Filter: (mk.movie_id = t.id)
              ->  Nested Loop  (cost=4.83..11364.19 rows=1 width=52)
                    ->  Nested Loop  (cost=4.41..11208.98 rows=344 width=56)
                          ->  Nested Loop  (cost=3.98..11088.45 rows=72 width=48)
                                ->  Nested Loop  (cost=3.55..11055.70 rows=72 width=37)
                                      ->  Nested Loop  (cost=3.12..10477.45 rows=1264 width=25)
                                            Join Filter: (cc.movie_id = ci.movie_id)
                                            ->  Nested Loop  (cost=2.55..10177.18 rows=33 width=13)
                                                  Join Filter: (it.id = mi_idx.info_type_id)
                                                  ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                        Filter: ((info)::text = 'rating'::text)
                                                  ->  Nested Loop  (cost=2.55..10128.32 rows=3716 width=17)
                                                        ->  Hash Join  (cost=2.12..2996.88 rows=8443 width=4)
                                                              Hash Cond: (cc.subject_id = cct1.id)
                                                              ->  Hash Join  (cost=1.06..2813.24 rows=33772 width=8)
                                                                    Hash Cond: (cc.status_id = cct2.id)
                                                                    ->  Seq Scan on complete_cast cc  (cost=0.00..2081.86 rows=135086 width=12)
                                                                    ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                                                          ->  Seq Scan on comp_cast_type cct2  (cost=0.00..1.05 rows=1 width=4)
                                                                                Filter: ((kind)::text ~~ '%complete%'::text)
                                                              ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                                                    ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
                                                                          Filter: ((kind)::text = 'cast'::text)
                                                        ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.83 rows=1 width=13)
                                                              Index Cond: (movie_id = cc.movie_id)
                                                              Filter: ((info)::text > '7.0'::text)
                                            ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..8.62 rows=38 width=12)
                                                  Index Cond: (movie_id = mi_idx.movie_id)
                                      ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.46 rows=1 width=20)
                                            Index Cond: (id = ci.person_role_id)
                                            Filter: ((name IS NOT NULL) AND (((name)::text ~~ '%man%'::text) OR ((name)::text ~~ '%Man%'::text)))
                                ->  Index Scan using name_pkey on name n  (cost=0.43..0.45 rows=1 width=19)
                                      Index Cond: (id = ci.person_id)
                          ->  Index Scan using movie_id_movie_keyword on movie_keyword mk  (cost=0.43..1.22 rows=45 width=8)
                                Index Cond: (movie_id = ci.movie_id)
                    ->  Index Scan using keyword_pkey on keyword k  (cost=0.42..0.45 rows=1 width=4)
                          Index Cond: (id = mk.keyword_id)
                          Filter: ((keyword)::text = ANY ('{superhero,marvel-comics,based-on-comic,tv-special,fight,violence,magnet,web,claw,laser}'::text[]))
              ->  Index Scan using title_pkey on title t  (cost=0.43..0.45 rows=1 width=25)
                    Index Cond: (id = ci.movie_id)
                    Filter: (production_year > 2000)
