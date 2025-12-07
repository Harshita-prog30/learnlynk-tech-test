## LearnLynk – Technical Assessment (Completed by Harshita Srivastava)
This project demonstrates a full-stack workflow using Supabase, Next.js, and Edge Functions. It includes designing database schemas, implementing secure RLS policies, building a serverless API for task creation, and creating a frontend dashboard to manage daily tasks. The assessment showcases backend–frontend integration and real-world product thinking.

## Project Files
**Download ZIP:** https://drive.google.com/drive/folders/1nt3bYOc13_N5myLiR34m_MIc9AoaFlfZ?usp=drive_link

I have used a free Supabase project, and the directory structure follows the exact format requested in the assignment.

## Overview

This assessment includes four technical tasks and one written question:

- Database Schema – backend/schema.sql  
- RLS Policies – backend/rls_policies.sql  
- Edge Function: create-task – backend/edge-functions/create-task/index.ts  
- Next.js Page: /dashboard/today – frontend/pages/dashboard/today.tsx  
- Stripe Checkout – included below in this README  

I have used:

- Supabase Postgres  
- Supabase Edge Functions (TypeScript)  
- Next.js + TypeScript  
- Supabase Auth + RLS  

## Task 1 — Database Schema

(File: backend/schema.sql)

I created the following tables with the required fields:

- leads  
- applications  
- tasks  

All tables include:

- id uuid primary key default gen_random_uuid(),  
- tenant_id uuid not null,  
- created_at timestamptz default now(),  
- updated_at timestamptz default now()  

Additional details implemented:

- applications.lead_id → FK to leads.id  
- tasks.application_id → FK to applications.id  
- tasks.type restricted to: call, email, review  
- tasks.due_at >= tasks.created_at  
- Indexes added for common tenant-level queries:  
  - Leads: tenant_id, owner_id, stage  
  - Applications: tenant_id, lead_id  
  - Tasks: tenant_id, due_at, status  

## Task 2 — Row Level Security

RLS was enabled on the leads table.  
I implemented policies based on the following rules:

Counselors can view:

- Leads they personally own, or  
- Leads belonging to any team they are part of  

Admins can view:

- All leads under their tenant  

Assumed existing tables:

- users(id, tenant_id, role)  
- teams(id, tenant_id)  
- user_teams(user_id, team_id)  

JWT includes:

- user_id  
- tenant_id  
- role  

I wrote:

- A SELECT policy that enforces the above visibility rules  
- An INSERT policy that allows counselors/admins to add leads under their tenant  

## Task 3 — Edge Function: create-task

(File: backend/edge-functions/create-task/index.ts)
This task implements a Supabase Edge Function that creates new tasks securely through a POST endpoint. It validates the input (task type and future due date), then inserts the task using the service role key and returns a success response with the generated task ID. It ensures proper error handling for invalid input and internal failures.
I created a POST endpoint that accepts:
{
  "application_id": "uuid",
  "task_type": "call",
  "due_at": "2025-01-01T12:00:00Z"
}

## Task 4 — Frontend Page: /dashboard/today

(File: frontend/pages/dashboard/today.tsx)

I built a page that:

Fetches all tasks due today (status ≠ completed)

Displays:

- type
- application_id
- due_at
- status

## Task 5 — Stripe Answer

- Implementing Stripe Checkout for Application Fee
- When a user initiates payment, I first insert a row into payment_requests with status = 'pending'.
- I call the Stripe API to create a Checkout Session with amount, currency, customer email, and success/cancel URLs.
- I store the session ID (stripe_session_id) back into payment_requests.
- User is redirected to Stripe Checkout to complete the payment.
- A Stripe webhook listens for checkout.session.completed.
- On receiving the webhook, I verify the event signature for security.
- After successful payment, I update payment_requests.status = 'paid'.
- I also update the related application stage, such as moving it to “Fee Paid” or similar workflow stage.
- Any errors during webhook handling are logged and retried safely.

This README and repository include all tasks as required.
Thank you for reviewing my work!
