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
                    'fight')
  AND kt.kind = 'movie'
  AND mi_idx.info > '8.0'
  AND t.production_year > 2005
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



Aggregate  (cost=7445.39..7445.40 rows=1 width=96)
  ->  Nested Loop  (cost=9.48..7445.38 rows=1 width=38)
        Join Filter: (cct1.id = cc.subject_id)
        ->  Seq Scan on comp_cast_type cct1  (cost=0.00..1.05 rows=1 width=4)
              Filter: ((kind)::text = 'cast'::text)
        ->  Nested Loop  (cost=9.48..7444.32 rows=1 width=42)
              Join Filter: (cct2.id = cc.status_id)
              ->  Seq Scan on comp_cast_type cct2  (cost=0.00..1.05 rows=1 width=4)
                    Filter: ((kind)::text ~~ '%complete%'::text)
              ->  Nested Loop  (cost=9.48..7443.26 rows=1 width=46)
                    ->  Nested Loop  (cost=9.06..7442.78 rows=1 width=54)
                          ->  Nested Loop  (cost=8.63..7442.32 rows=1 width=58)
                                ->  Nested Loop  (cost=8.20..7435.92 rows=14 width=46)
                                      Join Filter: (t.id = ci.movie_id)
                                      ->  Nested Loop  (cost=7.64..7433.90 rows=1 width=34)
                                            Join Filter: (kt.id = t.kind_id)
                                            ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=4)
                                                  Filter: ((kind)::text = 'movie'::text)
                                            ->  Nested Loop  (cost=7.64..7432.80 rows=1 width=38)
                                                  ->  Nested Loop  (cost=7.21..7432.31 rows=1 width=13)
                                                        Join Filter: (mi_idx.info_type_id = it.id)
                                                        ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                              Filter: ((info)::text = 'rating'::text)
                                                        ->  Nested Loop  (cost=7.21..7429.71 rows=15 width=17)
                                                              ->  Nested Loop  (cost=6.78..7361.15 rows=135 width=4)
                                                                    ->  Seq Scan on keyword k  (cost=0.00..2961.55 rows=4 width=4)
                                                                          Filter: ((keyword)::text = ANY ('{superhero,marvel-comics,based-on-comic,fight}'::text[]))
                                                                    ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1096.87 rows=303 width=8)
                                                                          Recheck Cond: (keyword_id = k.id)
                                                                          ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                                Index Cond: (keyword_id = k.id)
                                                              ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.50 rows=1 width=13)
                                                                    Index Cond: (movie_id = mk.movie_id)
                                                                    Filter: ((info)::text > '8.0'::text)
                                                  ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=25)
                                                        Index Cond: (id = mk.movie_id)
                                                        Filter: (production_year > 2005)
                                      ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.54 rows=38 width=12)
                                            Index Cond: (movie_id = mk.movie_id)
                                ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.46 rows=1 width=20)
                                      Index Cond: (id = ci.person_role_id)
                                      Filter: ((name IS NOT NULL) AND (((name)::text ~~ '%man%'::text) OR ((name)::text ~~ '%Man%'::text)))
                          ->  Index Only Scan using name_pkey on name n  (cost=0.43..0.45 rows=1 width=4)
                                Index Cond: (id = ci.person_id)
                    ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..0.46 rows=2 width=12)
                          Index Cond: (movie_id = t.id)
