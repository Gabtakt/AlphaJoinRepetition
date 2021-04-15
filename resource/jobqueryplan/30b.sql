SELECT MIN(mi.info) AS movie_budget,
       MIN(mi_idx.info) AS movie_votes,
       MIN(n.name) AS writer,
       MIN(t.title) AS complete_gore_movie
FROM complete_cast AS cc,
     comp_cast_type AS cct1,
     comp_cast_type AS cct2,
     cast_info AS ci,
     info_type AS it1,
     info_type AS it,
     keyword AS k,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE cct1.kind IN ('cast',
                    'crew')
  AND cct2.kind = 'complete+verified'
  AND ci.note IN ('(writer)',
                  '(head writer)',
                  '(written by)',
                  '(story)',
                  '(story editor)')
  AND it1.info = 'genres'
  AND it.info = 'votes'
  AND k.keyword IN ('murder',
                    'violence',
                    'blood',
                    'gore',
                    'death',
                    'female-nudity',
                    'hospital')
  AND mi.info IN ('Horror',
                  'Thriller')
  AND n.gender = 'm'
  AND t.production_year > 2000
  AND (t.title LIKE '%Freddy%'
       OR t.title LIKE '%Jason%'
       OR t.title LIKE 'Saw%')
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = ci.movie_id
  AND t.id = mk.movie_id
  AND t.id = cc.movie_id
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND ci.movie_id = mk.movie_id
  AND ci.movie_id = cc.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mk.movie_id
  AND mi.movie_id = cc.movie_id
  AND mi_idx.movie_id = mk.movie_id
  AND mi_idx.movie_id = cc.movie_id
  AND mk.movie_id = cc.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id
  AND k.id = mk.keyword_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id;



Aggregate  (cost=8733.77..8733.78 rows=1 width=128)
  ->  Nested Loop  (cost=1010.45..8733.76 rows=1 width=80)
        ->  Nested Loop  (cost=1010.31..8733.58 rows=1 width=84)
              Join Filter: (t.id = mi_idx.movie_id)
              ->  Nested Loop  (cost=1009.88..8732.76 rows=1 width=95)
                    ->  Nested Loop  (cost=1009.45..8731.72 rows=1 width=84)
                          Join Filter: (t.id = ci.movie_id)
                          ->  Nested Loop  (cost=1008.89..8701.89 rows=1 width=76)
                                ->  Nested Loop  (cost=1008.76..8701.72 rows=1 width=80)
                                      ->  Nested Loop  (cost=1008.62..8701.54 rows=1 width=84)
                                            Join Filter: (t.id = mi.movie_id)
                                            ->  Nested Loop  (cost=1008.18..8683.11 rows=1 width=33)
                                                  ->  Nested Loop  (cost=1008.05..8682.94 rows=1 width=37)
                                                        Join Filter: (t.id = cc.movie_id)
                                                        ->  Gather  (cost=1007.63..8682.11 rows=1 width=25)
                                                              Workers Planned: 2
                                                              ->  Nested Loop  (cost=7.63..7682.01 rows=1 width=25)
                                                                    ->  Nested Loop  (cost=7.20..7600.98 rows=98 width=4)
                                                                          ->  Parallel Index Scan using keyword_pkey on keyword k  (cost=0.42..4353.88 rows=3 width=4)
                                                                                Filter: ((keyword)::text = ANY ('{murder,violence,blood,gore,death,female-nudity,hospital}'::text[]))
                                                                          ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1079.34 rows=303 width=8)
                                                                                Recheck Cond: (keyword_id = k.id)
                                                                                ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                                      Index Cond: (keyword_id = k.id)
                                                                    ->  Index Scan using title_pkey on title t  (cost=0.43..0.83 rows=1 width=21)
                                                                          Index Cond: (id = mk.movie_id)
                                                                          Filter: ((production_year > 2000) AND (((title)::text ~~ '%Freddy%'::text) OR ((title)::text ~~ '%Jason%'::text) OR ((title)::text ~~ 'Saw%'::text)))
                                                        ->  Index Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..0.81 rows=2 width=12)
                                                              Index Cond: (movie_id = mk.movie_id)
                                                  ->  Index Scan using comp_cast_type_pkey on comp_cast_type cct2  (cost=0.13..0.15 rows=1 width=4)
                                                        Index Cond: (id = cc.status_id)
                                                        Filter: ((kind)::text = 'complete+verified'::text)
                                            ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..18.42 rows=1 width=51)
                                                  Index Cond: (movie_id = mk.movie_id)
                                                  Filter: ((info)::text = ANY ('{Horror,Thriller}'::text[]))
                                      ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.16 rows=1 width=4)
                                            Index Cond: (id = mi.info_type_id)
                                            Filter: ((info)::text = 'genres'::text)
                                ->  Index Scan using comp_cast_type_pkey on comp_cast_type cct1  (cost=0.13..0.15 rows=1 width=4)
                                      Index Cond: (id = cc.subject_id)
                                      Filter: ((kind)::text = ANY ('{cast,crew}'::text[]))
                          ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..29.82 rows=1 width=8)
                                Index Cond: (movie_id = mk.movie_id)
                                Filter: ((note)::text = ANY ('{(writer),"(head writer)","(written by)",(story),"(story editor)"}'::text[]))
                    ->  Index Scan using name_pkey on name n  (cost=0.43..1.04 rows=1 width=19)
                          Index Cond: (id = ci.person_id)
                          Filter: ((gender)::text = 'm'::text)
              ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.78 rows=3 width=13)
                    Index Cond: (movie_id = mk.movie_id)
        ->  Index Scan using info_type_pkey on info_type it  (cost=0.14..0.16 rows=1 width=4)
              Index Cond: (id = mi_idx.info_type_id)
              Filter: ((info)::text = 'votes'::text)
