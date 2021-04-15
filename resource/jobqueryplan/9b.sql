SELECT MIN(an.name) AS alternative_name,
       MIN(chn.name) AS voiced_character,
       MIN(n.name) AS voicing_actress,
       MIN(t.title) AS american_movie
FROM aka_name AS an,
     char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     movie_companies AS mc,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note = '(voice)'
  AND cn.country_code = '[us]'
  AND mc.note LIKE '%(200%)%'
  AND (mc.note LIKE '%(USA)%'
       OR mc.note LIKE '%(worldwide)%')
  AND n.gender = 'f'
  AND n.name LIKE '%Angel%'
  AND rt.role = 'actress'
  AND t.production_year BETWEEN 2007 AND 2010
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND ci.movie_id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND n.id = ci.person_id
  AND chn.id = ci.person_role_id
  AND an.person_id = n.id
  AND an.person_id = ci.person_id;



Aggregate  (cost=83247.10..83247.11 rows=1 width=128)
  ->  Nested Loop  (cost=1003.86..83247.09 rows=1 width=64)
        ->  Nested Loop  (cost=1003.43..83246.39 rows=1 width=55)
              ->  Nested Loop  (cost=1003.01..83245.82 rows=1 width=59)
                    ->  Gather  (cost=1002.58..83245.11 rows=1 width=47)
                          Workers Planned: 2
                          ->  Nested Loop  (cost=2.58..82245.01 rows=1 width=47)
                                ->  Hash Join  (cost=2.15..82244.30 rows=1 width=39)
                                      Hash Cond: (ci.role_id = rt.id)
                                      ->  Nested Loop  (cost=0.99..82243.08 rows=15 width=43)
                                            Join Filter: (n.id = ci.person_id)
                                            ->  Nested Loop  (cost=0.42..82142.98 rows=8 width=39)
                                                  ->  Parallel Seq Scan on name n  (cost=0.00..81659.82 rows=39 width=19)
                                                        Filter: (((name)::text ~~ '%Angel%'::text) AND ((gender)::text = 'f'::text))
                                                  ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..12.37 rows=2 width=20)
                                                        Index Cond: (person_id = n.id)
                                            ->  Index Scan using person_id_cast_info on cast_info ci  (cost=0.56..12.39 rows=10 width=16)
                                                  Index Cond: (person_id = an.person_id)
                                                  Filter: ((note)::text = '(voice)'::text)
                                      ->  Hash  (cost=1.15..1.15 rows=1 width=4)
                                            ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                                  Filter: ((role)::text = 'actress'::text)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.70 rows=1 width=8)
                                      Index Cond: (movie_id = ci.movie_id)
                                      Filter: (((note)::text ~~ '%(200%)%'::text) AND (((note)::text ~~ '%(USA)%'::text) OR ((note)::text ~~ '%(worldwide)%'::text)))
                    ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.71 rows=1 width=20)
                          Index Cond: (id = ci.person_role_id)
              ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.57 rows=1 width=4)
                    Index Cond: (id = mc.company_id)
                    Filter: ((country_code)::text = '[us]'::text)
        ->  Index Scan using title_pkey on title t  (cost=0.43..0.70 rows=1 width=21)
              Index Cond: (id = ci.movie_id)
              Filter: ((production_year >= 2007) AND (production_year <= 2010))
