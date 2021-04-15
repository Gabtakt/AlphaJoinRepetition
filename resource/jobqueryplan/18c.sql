SELECT MIN(mi.info) AS movie_budget,
       MIN(mi_idx.info) AS movie_votes,
       MIN(t.title) AS movie_title
FROM cast_info AS ci,
     info_type AS it1,
     info_type AS it,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     name AS n,
     title AS t
WHERE ci.note IN ('(writer)',
                  '(head writer)',
                  '(written by)',
                  '(story)',
                  '(story editor)')
  AND it1.info = 'genres'
  AND it.info = 'votes'
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
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id;



Finalize Aggregate  (cost=75887.19..75887.20 rows=1 width=96)
  ->  Gather  (cost=75886.97..75887.18 rows=2 width=96)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=74886.97..74886.98 rows=1 width=96)
              ->  Nested Loop  (cost=6.71..74886.89 rows=10 width=65)
                    ->  Nested Loop  (cost=6.28..74870.35 rows=24 width=69)
                          ->  Nested Loop  (cost=5.72..74403.59 rows=19 width=77)
                                Join Filter: (mi.movie_id = t.id)
                                ->  Hash Join  (cost=5.29..74392.48 rows=19 width=56)
                                      Hash Cond: (mi.info_type_id = it1.id)
                                      ->  Nested Loop  (cost=2.86..74384.25 rows=2131 width=60)
                                            ->  Hash Join  (cost=2.43..15253.60 rows=5089 width=9)
                                                  Hash Cond: (mi_idx.info_type_id = it.id)
                                                  ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..13685.15 rows=575015 width=13)
                                                  ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                        ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                              Filter: ((info)::text = 'votes'::text)
                                            ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..11.61 rows=1 width=51)
                                                  Index Cond: (movie_id = mi_idx.movie_id)
                                                  Filter: ((info)::text = ANY ('{Horror,Action,Sci-Fi,Thriller,Crime,War}'::text[]))
                                      ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                            ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                                  Filter: ((info)::text = 'genres'::text)
                                ->  Index Scan using title_pkey on title t  (cost=0.43..0.57 rows=1 width=21)
                                      Index Cond: (id = mi_idx.movie_id)
                          ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..24.56 rows=1 width=8)
                                Index Cond: (movie_id = t.id)
                                Filter: ((note)::text = ANY ('{(writer),"(head writer)","(written by)",(story),"(story editor)"}'::text[]))
                    ->  Index Scan using name_pkey on name n  (cost=0.43..0.69 rows=1 width=4)
                          Index Cond: (id = ci.person_id)
                          Filter: ((gender)::text = 'm'::text)
