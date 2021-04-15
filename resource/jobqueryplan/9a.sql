SELECT MIN(an.name) AS alternative_name,
       MIN(chn.name) AS character_name,
       MIN(t.title) AS movie
FROM aka_name AS an,
     char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     movie_companies AS mc,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code = '[us]'
  AND mc.note IS NOT NULL
  AND (mc.note LIKE '%(USA)%'
       OR mc.note LIKE '%(worldwide)%')
  AND n.gender = 'f'
  AND n.name LIKE '%Ang%'
  AND rt.role = 'actress'
  AND t.production_year BETWEEN 2005 AND 2015
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND ci.movie_id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND n.id = ci.person_id
  AND chn.id = ci.person_role_id
  AND an.person_id = n.id
  AND an.person_id = ci.person_id;



Aggregate  (cost=83257.99..83258.00 rows=1 width=96)
  ->  Nested Loop  (cost=1003.86..83257.98 rows=1 width=49)
        ->  Nested Loop  (cost=1003.44..83257.49 rows=1 width=53)
              Join Filter: (ci.movie_id = mc.movie_id)
              ->  Gather  (cost=1003.01..83256.84 rows=1 width=57)
                    Workers Planned: 2
                    ->  Nested Loop  (cost=3.01..82256.74 rows=1 width=57)
                          ->  Nested Loop  (cost=2.58..82256.09 rows=1 width=45)
                                ->  Hash Join  (cost=2.15..82254.78 rows=2 width=24)
                                      Hash Cond: (ci.role_id = rt.id)
                                      ->  Nested Loop  (cost=0.99..82253.54 rows=19 width=28)
                                            Join Filter: (n.id = ci.person_id)
                                            ->  Nested Loop  (cost=0.42..82142.98 rows=8 width=24)
                                                  ->  Parallel Seq Scan on name n  (cost=0.00..81659.82 rows=39 width=4)
                                                        Filter: (((name)::text ~~ '%Ang%'::text) AND ((gender)::text = 'f'::text))
                                                  ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..12.37 rows=2 width=20)
                                                        Index Cond: (person_id = n.id)
                                            ->  Index Scan using person_id_cast_info on cast_info ci  (cost=0.56..13.67 rows=12 width=16)
                                                  Index Cond: (person_id = an.person_id)
                                                  Filter: ((note)::text = ANY ('{(voice),"(voice: Japanese version)","(voice) (uncredited)","(voice: English version)"}'::text[]))
                                      ->  Hash  (cost=1.15..1.15 rows=1 width=4)
                                            ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                                  Filter: ((role)::text = 'actress'::text)
                                ->  Index Scan using title_pkey on title t  (cost=0.43..0.65 rows=1 width=21)
                                      Index Cond: (id = ci.movie_id)
                                      Filter: ((production_year >= 2005) AND (production_year <= 2015))
                          ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.66 rows=1 width=20)
                                Index Cond: (id = ci.person_role_id)
              ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.64 rows=1 width=8)
                    Index Cond: (movie_id = t.id)
                    Filter: ((note IS NOT NULL) AND (((note)::text ~~ '%(USA)%'::text) OR ((note)::text ~~ '%(worldwide)%'::text)))
        ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.48 rows=1 width=4)
              Index Cond: (id = mc.company_id)
              Filter: ((country_code)::text = '[us]'::text)
