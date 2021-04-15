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
  AND it.info = 'rating'
  AND mi.info IN ('Horror',
                  'Thriller')
  AND mi.note IS NULL
  AND mi_idx.info > '8.0'
  AND n.gender IS NOT NULL
  AND n.gender = 'f'
  AND t.production_year BETWEEN 2008 AND 2014
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id;



Aggregate  (cost=17462.26..17462.27 rows=1 width=96)
  ->  Nested Loop  (cost=1004.43..17462.25 rows=1 width=65)
        ->  Nested Loop  (cost=1004.00..17461.56 rows=1 width=69)
              ->  Gather  (cost=1003.43..17436.21 rows=1 width=77)
                    Workers Planned: 2
                    ->  Nested Loop  (cost=3.43..16436.11 rows=1 width=77)
                          ->  Nested Loop  (cost=3.29..16434.79 rows=8 width=81)
                                ->  Nested Loop  (cost=2.86..15786.98 rows=55 width=30)
                                      ->  Hash Join  (cost=2.43..15179.52 rows=177 width=9)
                                            Hash Cond: (mi_idx.info_type_id = it.id)
                                            ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..15122.68 rows=19980 width=13)
                                                  Filter: ((info)::text > '8.0'::text)
                                            ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                  ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                        Filter: ((info)::text = 'rating'::text)
                                      ->  Index Scan using title_pkey on title t  (cost=0.43..3.43 rows=1 width=21)
                                            Index Cond: (id = mi_idx.movie_id)
                                            Filter: ((production_year >= 2008) AND (production_year <= 2014))
                                ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..11.77 rows=1 width=51)
                                      Index Cond: (movie_id = t.id)
                                      Filter: ((note IS NULL) AND ((info)::text = ANY ('{Horror,Thriller}'::text[])))
                          ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.16 rows=1 width=4)
                                Index Cond: (id = mi.info_type_id)
                                Filter: ((info)::text = 'genres'::text)
              ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..25.34 rows=1 width=8)
                    Index Cond: (movie_id = t.id)
                    Filter: ((note)::text = ANY ('{(writer),"(head writer)","(written by)",(story),"(story editor)"}'::text[]))
        ->  Index Scan using name_pkey on name n  (cost=0.43..0.69 rows=1 width=4)
              Index Cond: (id = ci.person_id)
              Filter: ((gender IS NOT NULL) AND ((gender)::text = 'f'::text))
