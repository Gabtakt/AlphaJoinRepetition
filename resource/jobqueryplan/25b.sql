SELECT MIN(mi.info) AS movie_budget,
       MIN(mi_idx.info) AS movie_votes,
       MIN(n.name) AS male_writer,
       MIN(t.title) AS violent_movie_title
FROM cast_info AS ci,
     info_type AS it1,
     info_type AS it,
     keyword AS k,
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
  AND it1.info = 'genres'
  AND it.info = 'votes'
  AND k.keyword IN ('murder',
                    'blood',
                    'gore',
                    'death',
                    'female-nudity')
  AND mi.info = 'Horror'
  AND n.gender = 'm'
  AND t.production_year > 2010
  AND t.title LIKE 'Vampire%'
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = ci.movie_id
  AND t.id = mk.movie_id
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND ci.movie_id = mk.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mk.movie_id
  AND mi_idx.movie_id = mk.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id
  AND k.id = mk.keyword_id;



Aggregate  (cost=7501.00..7501.01 rows=1 width=128)
  ->  Nested Loop  (cost=1009.77..7500.99 rows=1 width=80)
        ->  Nested Loop  (cost=1009.34..7499.96 rows=1 width=69)
              ->  Nested Loop  (cost=1009.20..7499.78 rows=1 width=73)
                    Join Filter: (t.id = mi_idx.movie_id)
                    ->  Nested Loop  (cost=1008.77..7498.97 rows=1 width=80)
                          ->  Nested Loop  (cost=1008.63..7498.79 rows=1 width=84)
                                Join Filter: (t.id = mi.movie_id)
                                ->  Nested Loop  (cost=1008.20..7480.56 rows=1 width=33)
                                      Join Filter: (t.id = ci.movie_id)
                                      ->  Gather  (cost=1007.63..7450.87 rows=1 width=25)
                                            Workers Planned: 2
                                            ->  Nested Loop  (cost=7.63..6450.77 rows=1 width=25)
                                                  ->  Nested Loop  (cost=7.20..6393.93 rows=70 width=4)
                                                        ->  Parallel Index Scan using keyword_pkey on keyword k  (cost=0.42..4208.16 rows=2 width=4)
                                                              Filter: ((keyword)::text = ANY ('{murder,blood,gore,death,female-nudity}'::text[]))
                                                        ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1089.86 rows=303 width=8)
                                                              Recheck Cond: (keyword_id = k.id)
                                                              ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                    Index Cond: (keyword_id = k.id)
                                                  ->  Index Scan using title_pkey on title t  (cost=0.43..0.81 rows=1 width=21)
                                                        Index Cond: (id = mk.movie_id)
                                                        Filter: ((production_year > 2010) AND ((title)::text ~~ 'Vampire%'::text))
                                      ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..29.68 rows=1 width=8)
                                            Index Cond: (movie_id = mk.movie_id)
                                            Filter: ((note)::text = ANY ('{(writer),"(head writer)","(written by)",(story),"(story editor)"}'::text[]))
                                ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..18.22 rows=1 width=51)
                                      Index Cond: (movie_id = mk.movie_id)
                                      Filter: ((info)::text = 'Horror'::text)
                          ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.16 rows=1 width=4)
                                Index Cond: (id = mi.info_type_id)
                                Filter: ((info)::text = 'genres'::text)
                    ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.77 rows=3 width=13)
                          Index Cond: (movie_id = mk.movie_id)
              ->  Index Scan using info_type_pkey on info_type it  (cost=0.14..0.16 rows=1 width=4)
                    Index Cond: (id = mi_idx.info_type_id)
                    Filter: ((info)::text = 'votes'::text)
        ->  Index Scan using name_pkey on name n  (cost=0.43..1.03 rows=1 width=19)
              Index Cond: (id = ci.person_id)
              Filter: ((gender)::text = 'm'::text)
