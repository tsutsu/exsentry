defmodule ExSentryTest do
  use ExSpec, async: false
  doctest ExSentry

  context "new" do
    it "returns pid" do
      assert(is_pid(ExSentry.new("")))
    end
  end


  context "capture_message(client, message, opts)" do
    it "returns :ok" do
      assert(:ok == ExSentry.capture_message(:exsentry_default_client, "hi", []))
    end
  end

  context "capture_message(message, opts)" do
    it "returns :ok" do
      assert(:ok == ExSentry.capture_message("hi", []))
    end
  end

  context "capture_message(client, message)" do
    it "returns :ok" do
      assert(:ok == ExSentry.capture_message(:exsentry_default_client, "hi"))
    end
  end

  context "capture_message(message)" do
    it "returns :ok" do
      assert(:ok == ExSentry.capture_message("hi"))
    end
  end


  context "capture_exception(client, exception, opts)" do
    it "returns :ok" do
      try do
        raise "omg"
      rescue
        e ->
          assert(:ok == ExSentry.capture_exception(:exsentry_default_client, e, []))
      end
    end
  end

  context "capture_exception(exception, opts)" do
    it "returns :ok" do
      try do
        raise "omg"
      rescue
        e ->
          assert(:ok == ExSentry.capture_exception(e, []))
      end
    end
  end

  context "capture_exception(client, exception)" do
    it "returns :ok" do
      try do
        raise "omg"
      rescue
        e ->
          assert(:ok == ExSentry.capture_exception(:exsentry_default_client, e))
      end
    end
  end

  context "capture_exception(exception)" do
    it "returns :ok" do
      try do
        raise "omg"
      rescue
        e ->
          assert(:ok == ExSentry.capture_exception(e))
      end
    end
  end


  context "capture_exceptions(client, opts, fun)" do
    it "invokes fun.()" do
      try do
        ExSentry.capture_exceptions(:exsentry_default_client, [], fn -> raise "omg" end)
      rescue
        e -> assert("omg" == e.message)
      end
    end
  end

  context "capture_exceptions(opts, fun)" do
    it "invokes fun.()" do
      try do
        ExSentry.capture_exceptions([], fn -> raise "omg" end)
      rescue
        e -> assert("omg" == e.message)
      end
    end
  end

  context "capture_exceptions(client, fun)" do
    it "invokes fun.()" do
      try do
        ExSentry.capture_exceptions(:exsentry_default_client, fn -> raise "omg" end)
      rescue
        e -> assert("omg" == e.message)
      end
    end
  end

  context "capture_exceptions(fun)" do
    it "invokes fun.()" do
      try do
        ExSentry.capture_exceptions(fn -> raise "omg" end)
      rescue
        e -> assert("omg" == e.message)
      end
    end
  end

end
