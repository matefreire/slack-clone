import { Button } from "@/components/ui/button";

export default function Home() {
  return (
    <div>
      {/* Example of a component */}
      <h1 className="text-2xl font-bold text-emerald-600">Hello World</h1>
      <p>This is a slack clone</p>
      <Button variant={"destructive"}>Click me</Button>
    </div>
  )
}
