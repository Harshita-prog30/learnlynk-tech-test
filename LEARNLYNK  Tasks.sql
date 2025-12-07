--Section 1
-- LEARNLYNK SCHEMA


-- Table 1: leads
CREATE TABLE leads (
    id INTEGER PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    owner_id INTEGER,
    stage TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Index for searching leads by owner
CREATE INDEX idx_leads_owner ON leads(owner_id);


-- Table 2: applications
CREATE TABLE applications (
    id INTEGER PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    lead_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (lead_id) REFERENCES leads(id)
);

-- Table 3: tasks
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    related_id INTEGER NOT NULL, -- link to application
    type TEXT NOT NULL,
    due_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    FOREIGN KEY (related_id) REFERENCES applications(id),

    -- Rule: due date cannot be before creation
    CHECK (due_at >= created_at),

    -- Rule: type must be one of these
    CHECK (type IN ('call', 'email', 'review'))
);

-- Index for finding tasks due today
CREATE INDEX idx_tasks_due_today ON tasks(due_at);


--Section 2

--Step 1 — Correct SELECT inside IN()



owner_id IN (
    SELECT ut.user_id
    FROM user_teams ut
    WHERE ut.team_id IN (
        SELECT team_id
        FROM user_teams
        WHERE user_id = (auth.jwt()->>'user_id')::int
    )
)




--Step 2 
CREATE POLICY select_leads_policy
ON leads
FOR SELECT
USING (
    auth.jwt()->>'role' = 'admin'
    OR owner_id = (auth.jwt()->>'user_id')::int
    OR owner_id IN (
        SELECT ut.user_id
        FROM user_teams ut
        WHERE ut.team_id IN (
            SELECT team_id
            FROM user_teams
            WHERE user_id = (auth.jwt()->>'user_id')::int
        )
    )
);

--Step 3 — INSERT Policy 
CREATE POLICY insert_leads_policy
ON leads
FOR INSERT
WITH CHECK (
    auth.jwt()->>'role' = 'admin'
    OR owner_id = (auth.jwt()->>'user_id')::int
);

--SECTION 5 — Integration Task

1.I would create a Stripe Checkout session on the backend with the fee amount and success/cancel URLs.

2.Before redirecting, I would store the payment request in the database with status “pending.”

3.On the frontend, the user is sent to Stripe’s payment page using the session ID.

4.Stripe sends a webhook to our backend after the payment is completed.

5.I would verify the webhook to make sure it’s really from Stripe.

6.On successful payment, I would update the payment status in the database to “paid.”

7.Then I would update the application stage or timeline to reflect the fee is done.

8.Finally, I could notify the user that their payment was successful.


















