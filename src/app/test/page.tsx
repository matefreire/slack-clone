"use client";

import { useQuery } from "convex/react";
import { api } from "../../../convex/_generated/api";

const Page = () => {
  const tasks = useQuery(api.tasks.get);
  return (
    <div>
      <h1>Test page</h1>
      <ul>
        {tasks?.map((task) => (
          <li key={task._id}>{task.text}</li>
        ))}
      </ul>
    </div>
  );
};

export default Page;
