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
                    'violence',
                    'blood',
                    'gore',
                    'death',
                    'female-nudity',
                    'hospital')
  AND mi.info IN ('Horror',
                  'Action',
                  'Sci-Fi',
                  'Thriller',
                  'Crime',
                  'War')
  AND n.gender = 'm'
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



Aggregate  (cost=8763.93..8763.94 rows=1 width=128)
  ->  Nested Loop  (cost=1012.06..8763.92 rows=1 width=80)
        Join Filter: (mi.movie_id = t.id)
        ->  Nested Loop  (cost=1011.63..8763.10 rows=1 width=79)
              ->  Nested Loop  (cost=1011.20..8762.07 rows=1 width=68)
                    Join Filter: (mi.movie_id = ci.movie_id)
                    ->  Gather  (cost=1010.63..8732.38 rows=1 width=60)
                          Workers Planned: 2
                          ->  Nested Loop  (cost=10.63..7732.28 rows=1 width=60)
                                ->  Nested Loop  (cost=10.49..7732.10 rows=1 width=64)
                                      Join Filter: (mi_idx.movie_id = mi.movie_id)
                                      ->  Hash Join  (cost=10.05..7676.76 rows=3 width=13)
                                            Hash Cond: (mi_idx.info_type_id = it.id)
                                            ->  Nested Loop  (cost=7.63..7673.47 rows=316 width=17)
                                                  ->  Nested Loop  (cost=7.20..7595.01 rows=98 width=4)
                                                        ->  Parallel Index Scan using keyword_pkey on keyword k  (cost=0.42..4347.92 rows=3 width=4)
                                                              Filter: ((keyword)::text = ANY ('{murder,violence,blood,gore,death,female-nudity,hospital}'::text[]))
                                                        ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1079.34 rows=303 width=8)
                                                              Recheck Cond: (keyword_id = k.id)
                                                              ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                                    Index Cond: (keyword_id = k.id)
                                                  ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.77 rows=3 width=13)
                                                        Index Cond: (movie_id = mk.movie_id)
                                            ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                  ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                        Filter: ((info)::text = 'votes'::text)
                                      ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..18.43 rows=1 width=51)
                                            Index Cond: (movie_id = mk.movie_id)
                                            Filter: ((info)::text = ANY ('{Horror,Action,Sci-Fi,Thriller,Crime,War}'::text[]))
                                ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.16 rows=1 width=4)
                                      Index Cond: (id = mi.info_type_id)
                                      Filter: ((info)::text = 'genres'::text)
                    ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..29.68 rows=1 width=8)
                          Index Cond: (movie_id = mk.movie_id)
                          Filter: ((note)::text = ANY ('{(writer),"(head writer)","(written by)",(story),"(story editor)"}'::text[]))
              ->  Index Scan using name_pkey on name n  (cost=0.43..1.03 rows=1 width=19)
                    Index Cond: (id = ci.person_id)
                    Filter: ((gender)::text = 'm'::text)
        ->  Index Scan using title_pkey on title t  (cost=0.43..0.81 rows=1 width=21)
              Index Cond: (id = mk.movie_id)
