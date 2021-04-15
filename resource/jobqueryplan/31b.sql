SELECT MIN(mi.info) AS movie_budget,
       MIN(mi_idx.info) AS movie_votes,
       MIN(n.name) AS writer,
       MIN(t.title) AS violent_liongate_movie
FROM cast_info AS ci,
     company_name AS cn,
     info_type AS it1,
     info_type AS it,
     keyword AS k,
     movie_companies AS mc,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE ci.note IN ('(writer)',
                  '(head writer)',
                  '(written by)',
                  '(story)',
                  '(story editor)')
  AND cn.name LIKE 'Lionsgate%'
  AND it1.info = 'genres'
  AND it.info = 'votes'
  AND k.keyword IN ('murder',
                    'violence',
                    'blood',
                    'gore',
                    'death',
                    'female-nudity',
                    'hospital')
  AND mc.note LIKE '%(Blu-ray)%'
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
  AND t.id = mc.movie_id
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND ci.movie_id = mk.movie_id
  AND ci.movie_id = mc.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mk.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi_idx.movie_id = mk.movie_id
  AND mi_idx.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id
  AND k.id = mk.keyword_id
  AND cn.id = mc.company_id;



Aggregate  (cost=8991.06..8991.07 rows=1 width=128)
  ->  Nested Loop  (cost=1010.62..8991.05 rows=1 width=80)
        ->  Nested Loop  (cost=1010.19..8989.76 rows=1 width=69)
              ->  Nested Loop  (cost=1010.05..8989.57 rows=1 width=73)
                    Join Filter: (t.id = mi_idx.movie_id)
                    ->  Nested Loop  (cost=1009.62..8988.47 rows=1 width=84)
                          ->  Nested Loop  (cost=1009.48..8988.29 rows=1 width=88)
                                Join Filter: (t.id = mi.movie_id)
                                ->  Nested Loop  (cost=1009.05..8964.39 rows=1 width=37)
                                      ->  Nested Loop  (cost=1008.63..8955.61 rows=1 width=41)
                                            Join Filter: (t.id = mc.movie_id)
                                            ->  Nested Loop  (cost=1008.20..8953.44 rows=1 width=33)
                                                  Join Filter: (t.id = ci.movie_id)
                                                  ->  Gather  (cost=1007.63..8919.55 rows=1 width=25)
                                                        Workers Planned: 2
                                                        ->  Nested Loop  (cost=7.63..7919.45 rows=1 width=25)
                                                              ->  Nested Loop  (cost=7.20..7810.93 rows=98 width=4)
                                                                    ->  Parallel Index Scan using keyword_pkey on keyword k  (cost=0.42..4563.84 rows=3 width=4)
                                                                          Filter: ((keyword)::text = ANY ('{murder,violence,blood,gore,death,female-nudity,hospital}'::text[]))
                                                                    ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1079.34 rows=303 width=8)
                                                                          Recheck Cond: (keyword_id = k.id)
                                                                          ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                                Index Cond: (keyword_id = k.id)
                                                              ->  Index Scan using title_pkey on title t  (cost=0.43..1.11 rows=1 width=21)
                                                                    Index Cond: (id = mk.movie_id)
                                                                    Filter: ((production_year > 2000) AND (((title)::text ~~ '%Freddy%'::text) OR ((title)::text ~~ '%Jason%'::text) OR ((title)::text ~~ 'Saw%'::text)))
                                                  ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..33.88 rows=1 width=8)
                                                        Index Cond: (movie_id = mk.movie_id)
                                                        Filter: ((note)::text = ANY ('{(writer),"(head writer)","(written by)",(story),"(story editor)"}'::text[]))
                                            ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..2.16 rows=1 width=8)
                                                  Index Cond: (movie_id = mk.movie_id)
                                                  Filter: ((note)::text ~~ '%(Blu-ray)%'::text)
                                      ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..8.14 rows=1 width=4)
                                            Index Cond: (id = mc.company_id)
                                            Filter: ((name)::text ~~ 'Lionsgate%'::text)
                                ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..23.89 rows=1 width=51)
                                      Index Cond: (movie_id = mk.movie_id)
                                      Filter: ((info)::text = ANY ('{Horror,Thriller}'::text[]))
                          ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.16 rows=1 width=4)
                                Index Cond: (id = mi.info_type_id)
                                Filter: ((info)::text = 'genres'::text)
                    ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..1.07 rows=3 width=13)
                          Index Cond: (movie_id = mk.movie_id)
              ->  Index Scan using info_type_pkey on info_type it  (cost=0.14..0.16 rows=1 width=4)
                    Index Cond: (id = mi_idx.info_type_id)
                    Filter: ((info)::text = 'votes'::text)
        ->  Index Scan using name_pkey on name n  (cost=0.43..1.30 rows=1 width=19)
              Index Cond: (id = ci.person_id)
              Filter: ((gender)::text = 'm'::text)
